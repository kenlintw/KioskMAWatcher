# Kiosk Maintenance Page Automation

## Overview

This project automates the maintenance workflow for Miramar Cinemas self-service kiosks.

During scheduled backend maintenance:

1. Stop the Kiosk application.
2. Display a full-screen maintenance page to customers.
3. Perform backend maintenance.
4. Reboot the kiosk.
5. Automatically restore the kiosk application after Windows restarts.

---

## Maintenance Workflow

```
00:10
    │
    ├── Task Scheduler
    │       │
    │       └── Create show_maintenance.flag
    │
    ▼
MAWatcher.bat
    │
    ├── KillMainApModule.exe
    │
    └── Launch Edge Kiosk
            │
            ▼
    Maintenance Page

00:10 ~ 01:10
Backend Maintenance

01:10
    │
    └── Scheduled Reboot

Windows Startup

    │
    └── Startup Folder

            │
            ▼
    KioskClient.exe
```

---

# Components

## launchMAPage.bat

Responsible for switching the kiosk into maintenance mode.

Functions:

- Kill the running Kiosk application.
- Wait for shutdown to complete.
- Launch Microsoft Edge in kiosk mode.
- Display the maintenance page.

---

## MAWatcher.bat

Runs continuously after Windows login.

Responsibilities:

- Monitor the existence of:

```
show_maintenance.flag
```

- When detected:

    - Delete the flag file
    - Execute `launchMAPage.bat`

The watcher is started automatically from the Windows Startup folder.

---

## show_maintenance.flag

An empty trigger file.

Created by Task Scheduler.

When detected by MAWatcher:

- Maintenance page is displayed.

---

## KillMainApModule.exe

Existing utility.

Responsibilities:

- Stop the running Kiosk application.

---

## startKioskClient.bat

Existing startup script.

Executed automatically after Windows login.

Responsibilities:

- Check whether KioskClient.exe is already running.
- Start KioskClient.exe if necessary.

---

# Windows Startup Configuration

The following files are located in:

```
shell:startup
```

(Current User Startup Folder)

```
MAWatcher.bat
KioskClient.exe (shortcut)
```

This allows both components to run inside the interactive Windows desktop session.

---

# Scheduled Tasks

## Show Maintenance Page

Trigger

```
One Time
00:10
```

Program

```
C:\Windows\System32\cmd.exe
```

Arguments

```cmd
/c type nul > "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
```

Purpose

Create the trigger file.

---

## Reboot Kiosk

Trigger

```
One Time
01:10
```

Program

```
shutdown.exe
```

Arguments

```cmd
/r /f /t 0
```

Purpose

Restart Windows after backend maintenance.

---

# Maintenance Page

Displayed using Microsoft Edge Kiosk Mode.

Example:

```cmd
msedge.exe ^
    --kiosk file:///C:/MAPage/KioskMA.html ^
    --edge-kiosk-type=fullscreen
```

---

# Why MAWatcher Exists

Launching Microsoft Edge directly from Windows Task Scheduler caused the browser to execute in a non-interactive Windows session (Session 0 / Services).

Symptoms included:

- Browser not visible
- Browser hidden behind other windows
- Taskbar remaining visible
- Edge translation prompt appearing unexpectedly

Using a desktop-resident watcher allows Edge to be launched from the interactive user session, ensuring:

- Full-screen kiosk mode
- Correct window focus
- Taskbar hidden
- Maintenance page visible to customers

---

# Deployment

1. Copy scripts to:

```
C:\Users\Miramar\Documents\scripts
```

2. Add `MAWatcher.bat` (or its launcher) to:

```
shell:startup
```

3. Configure Scheduled Task:

- Show Maintenance Page
- Reboot Kiosk

4. Verify:

- Maintenance page appears correctly.
- Windows reboots.
- KioskClient.exe starts automatically after login.

---

# Tested Environment

- Windows 10
- Microsoft Edge (Kiosk Mode)
- Miramar Cinemas Self-Service Kiosk