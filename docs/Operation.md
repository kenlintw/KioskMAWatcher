# Operation

## Normal daily flow

### Before maintenance

The kiosk is running normally with:

```text
KioskClient.exe
```

The watcher is running in the background in the kiosk user's interactive session.

### Start of maintenance

Task Scheduler creates:

```text
C:\Users\Miramar\Documents\scripts\show_maintenance.flag
```

Within 5 seconds, the watcher:

1. Deletes the flag.
2. Runs `launchMAPage.bat`.
3. Stops the kiosk application.
4. Opens the local maintenance page in Edge kiosk mode.
5. Brings Edge to the foreground.

### End of maintenance

Task Scheduler runs:

```text
shutdown /r /f /t 0
```

After Windows restarts and the kiosk user signs in automatically, the existing Startup shortcut launches the normal kiosk application.

## Manual start

To display the maintenance page immediately, create the trigger file:

```cmd
type nul > "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
```

## Manual recovery

If a test must be cancelled:

1. Close Edge using an administrator-approved method.
2. Start the normal kiosk application manually, or restart Windows.
3. Confirm the trigger file no longer exists.

## Log file

`launchMAPage.bat` writes to:

```text
C:\Users\Miramar\Documents\scripts\launchMAPage.log
```

Check this file when Edge does not launch or a required executable cannot be found.
