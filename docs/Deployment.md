# Deployment

## Prerequisites

Confirm these components exist:

```text
C:\ITKiosk\Tool\KillMainApModule.exe
C:\MAPage\KioskMA.html
C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
```

Confirm the normal kiosk application already starts automatically after Windows login.

## 1. Copy the scripts

Create:

```text
C:\Users\Miramar\Documents\scripts
```

Copy these files into it:

```text
MAWatcher.bat
launchMAPage.bat
```

Review the paths at the top of `MAWatcher.bat` and `launchMAPage.bat`.

## 2. Start the watcher automatically

Press `Win + R`, enter:

```text
shell:startup
```

Create a shortcut to:

```text
C:\Users\Miramar\Documents\scripts\MAWatcher.bat
```

The watcher must run in the logged-in kiosk user's desktop session.

## 3. Create the maintenance task

Create a daily task at the desired start time.

Program:

```text
C:\Windows\System32\cmd.exe
```

Arguments:

```text
/c type nul > "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
```

The task only creates the trigger file. It does not launch Edge directly.

## 4. Create the reboot task

Create a daily task at the desired end time.

Program:

```text
C:\Windows\System32\shutdown.exe
```

Arguments:

```text
/r /f /t 0
```

## 5. Edge translation prompt

The script does not currently pass a launch switch to suppress this. Disable the following Edge setting instead:

```text
Settings > Languages > Offer to translate pages that aren't in a language I read
```

For centrally managed kiosks, use the Microsoft Edge policy:

```text
OfferTranslateEnabled = Disabled
```

## 6. Test

1. Run `MAWatcher.bat`.
2. Manually create the trigger file:

```cmd
type nul > "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
```

3. Wait up to 5 seconds.
4. Confirm the kiosk application closes.
5. Confirm the maintenance page fills the screen.
6. Confirm the taskbar and monitoring console cannot be reached.
7. Reboot and confirm `KioskClient.exe` starts normally.
