# Troubleshooting

## Edge process exists but no window is visible

### Cause

Edge was launched from a non-interactive Task Scheduler session, commonly Session 0.

### Fix

Do not launch Edge directly from the scheduled task. Have the task create the trigger file and let `MAWatcher.bat` launch Edge from the user's Startup session.

---

## Monitoring console remains above Edge

### Cause

The monitoring application retains foreground focus.

### Fix

The final script:

1. Force-closes any existing Edge instances.
2. Opens Edge in kiosk mode.
3. Waits three seconds.
4. Activates the Edge window.

Verify this command has not been removed from `launchMAPage.bat`:

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ws = New-Object -ComObject WScript.Shell; $ws.AppActivate('Edge') | Out-Null"
```

---

## Taskbar remains visible

### Cause

Edge is not the foreground kiosk window yet.

### Fix

Confirm Edge is started with:

```text
--kiosk
--edge-kiosk-type=fullscreen
```

Also retain the foreground activation command and the three-second startup delay.

---

## Translation popup appears

### Fixes

`launchMAPage.bat` does not currently pass a launch switch to suppress this. Disable Edge's translation offer in `edge://settings/languages`, or for centrally managed kiosks set the policy:

```text
OfferTranslateEnabled = Disabled
```

---

## Maintenance does not start

Check:

1. Is `MAWatcher.bat` running?
2. Does the Startup shortcut point to the correct file?
3. Was the trigger file created?
4. Are the script paths correct?
5. Does `launchMAPage.log` contain an error?

Manual trigger:

```cmd
type nul > "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
```

---

## Maintenance launches repeatedly

The flag file may not be deletable.

Check permissions on:

```text
C:\Users\Miramar\Documents\scripts
```

The kiosk user must be able to create and delete files there.

---

## Edge path is different

Check both locations:

```text
C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
C:\Program Files\Microsoft\Edge\Application\msedge.exe
```

Update the Edge path in the `start` command in `launchMAPage.bat`. Note: avoid storing this path in a variable and checking it with `if not exist "%VAR%" ( ... )` — the `(x86)` in the path breaks cmd.exe's parser when expanded inside a parenthesized block. See the comment at the top of `launchMAPage.bat`.

---

## Kiosk application does not return after reboot

This project assumes the existing kiosk startup mechanism remains configured.

Open:

```text
shell:startup
```

Confirm the shortcut to `KioskClient.exe` still exists and that automatic login still works.
