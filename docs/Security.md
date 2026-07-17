# Security Notes

## Customer isolation

The maintenance page must cover:

- The Windows taskbar
- The desktop
- The kiosk monitoring console
- Any command prompt windows

Test the full workflow using the touchscreen, not only with a keyboard and mouse.

## Local maintenance content

The project opens a local file:

```text
file:///C:/MAPage/KioskMA.html
```

Keep this file and its assets read-only for the kiosk user where practical.

## Batch file permissions

Customers must not be able to modify:

- `MAWatcher.bat`
- `launchMAPage.bat`
- Scheduled tasks
- The maintenance HTML
- The Startup folder

Use normal NTFS access controls appropriate to the kiosk environment.

## Forced process termination

The script terminates all Edge processes:

```text
taskkill /IM msedge.exe /F
```

This is acceptable for a dedicated kiosk but may cause data loss on a general-purpose workstation.

## Forced restart

The reboot task uses:

```text
shutdown /r /f /t 0
```

The `/f` option forces applications to close. Ensure the maintenance window allows all backend and local operations to finish before the reboot task runs.
