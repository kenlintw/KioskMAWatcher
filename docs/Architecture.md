# Architecture

## Problem

The first implementation launched Microsoft Edge directly from Windows Task Scheduler.

The scheduled task ran, and `msedge.exe` appeared in Task Manager, but the maintenance page was not visible. Process inspection showed Edge running in the **Services / Session 0** context.

Windows isolates Session 0 from the interactive user's desktop. A GUI process can therefore run successfully without displaying a usable window to the customer.

## Solution

The final design separates the trigger from the GUI launch:

1. Task Scheduler creates an empty flag file.
2. `MAWatcher.bat`, already running in the kiosk user's desktop session, detects the file.
3. The watcher calls `launchMAPage.bat`.
4. Edge is launched from the interactive user session.

## Window layering

The kiosk monitoring program leaves a console window open. Initially, that window and the taskbar could remain visible above or beside Edge until the touchscreen was used.

The final launch sequence solves this by:

1. Force-closing any existing `msedge.exe` processes.
2. Starting Edge with `--kiosk` and fullscreen kiosk mode.
3. Calling `WScript.Shell.AppActivate('Edge')` after a short delay.

This brings Edge to the foreground and causes the kiosk window to cover the taskbar and monitoring console.

## Design decisions

### Trigger file

A trigger file is simple, observable, and easy to test.

```text
show_maintenance.flag
```

The watcher deletes it before starting maintenance mode, preventing repeated launches.

### Polling interval

The watcher checks every 5 seconds. The maintenance page therefore appears within about 5 seconds of the flag being created. Polling creates negligible system load, so the interval can be lengthened if less frequent checks are preferred.

### Restart restores normal operation

The normal kiosk application already starts from the Windows Startup folder. Restarting Windows at the end of maintenance therefore resets the machine to its normal operating state without requiring an additional recovery script.
