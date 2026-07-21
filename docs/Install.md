# Installing Perl on a Windows Kiosk

The Perl port of the kiosk maintenance automation only needs **one**
external runtime: a Perl interpreter. The default Strawberry Perl
distribution already ships every module the script uses, so no `cpan`
installs are required on a clean machine.

---

## 1. Install Strawberry Perl

Strawberry Perl is the de-facto standard Perl distribution for
production Windows use. It includes:

- The Perl 5 interpreter (`perl.exe`).
- A C toolchain (`gcc`, `dmake`, `mingw`) so any CPAN module that needs
  XS compilation can be built later.
- The standard library, including `Win32::OLE`, `Win32::Process`,
  `Time::HiRes`, `Getopt::Long`, `Cwd`, `File::Basename`, `POSIX`.

### Steps

1. Download the latest 64-bit MSI from:
   <https://strawberryperl.com/>
2. Run the installer as a Windows administrator.
3. Accept the default install path:
   `C:\Strawberry\`
4. **Important:** keep the option **"Add Perl to PATH"** enabled.
   Without it, `perl` is not found from a fresh `cmd.exe` window.
5. Finish the installer and **sign out / sign in** (or reboot) so the
   new `PATH` is visible to Task Scheduler and the Startup folder.

### Verify the install

Open **PowerShell** or `cmd.exe` and run:

```powershell
perl -v
```

You should see something like:

```text
This is perl 5, version 40, subversion 0 (v5.40.0) ...
```

Then confirm the four modules the script uses:

```powershell
perl -MWin32::OLE -e "print 'Win32::OLE OK', qq{\n}"
perl -MTime::HiRes -e "print 'Time::HiRes OK', qq{\n}"
perl -MGetopt::Long -e "print 'Getopt::Long OK', qq{\n}"
perl -MPOSIX       -e "print 'POSIX OK', qq{\n}"
```

If all four print `OK`, the environment is ready.

---

## 2. Drop the script on the kiosk

Copy these two files to the scripts directory (e.g.
`C:\Users\Miramar\Documents\scripts\`):

```text
kioskMA.pl
kioskMA.cfg          (optional; copy kioskMA.cfg.example and edit)
```

`kioskMA.cfg` is optional. If you skip it, the script uses the
built-in defaults baked into `kioskMA.pl`. If you maintain multiple
kiosks with different paths, ship a per-kiosk `.cfg` and point the
Startup shortcut at it via `--config=`.

---

## 3. File association (usually automatic)

The Strawberry Perl installer registers `.pl` files so that double-
clicking them runs `perl.exe`. If for some reason the association is
missing on a particular kiosk, run once from an elevated shell:

```powershell
cmd /c assoc .pl=PerlScript
cmd /c ftype PerlScript=C:\Strawberry\perl\bin\perl.exe "%1" %*
```

---

## 4. Update the Startup shortcut

The original `.bat` workflow used a Startup shortcut to
`MAWatcher.bat`. Replace that shortcut with one that runs the Perl
watcher:

- **Target:**

  ```text
  C:\Strawberry\perl\bin\perl.exe
  ```

- **Arguments:**

  ```text
  "C:\Users\Miramar\Documents\scripts\kioskMA.pl" watch --interval=5
  ```

  (Adjust the path to wherever you placed `kioskMA.pl`.)

- **Start in:**

  ```text
  C:\Users\Miramar\Documents\scripts
  ```

You can create the shortcut manually in `shell:startup`, or generate it
from PowerShell:

```powershell
$wsh = New-Object -ComObject WScript.Shell
$lnk = $wsh.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\kioskMAWatcher.lnk")
$lnk.TargetPath       = 'C:\Strawberry\perl\bin\perl.exe'
$lnk.Arguments        = '"C:\Users\Miramar\Documents\scripts\kioskMA.pl" watch --interval=5'
$lnk.WorkingDirectory = 'C:\Users\Miramar\Documents\scripts'
$lnk.WindowStyle      = 7   # minimized
$lnk.Save()
```

`WindowStyle = 7` (minimized) keeps a tiny cmd window from sitting on
the desktop if Perl ever opens a console.

---

## 5. Smoke test the watcher

From a regular `cmd.exe` (NOT the Startup shortcut, so you can see
output), run the watcher with `--once`:

```powershell
perl "C:\Users\Miramar\Documents\scripts\kioskMA.pl" watch --once
```

It should print a single "Watcher started" line and exit. Then test the
launch sequence by creating the trigger file manually and running
`watch` again:

```powershell
perl "C:\Users\Miramar\Documents\scripts\kioskMA.pl" trigger
perl "C:\Users\Miramar\Documents\scripts\kioskMA.pl" watch --once
```

You should see Edge pop up in kiosk mode within ~3 seconds. If anything
fails, the log is at
`C:\Users\Miramar\Documents\scripts\launchMAPage.log` (or wherever
`log_file` points).

---

## 6. The original `.bat` files

The legacy `MAWatcher.bat`, `launchMAPage.bat`, and the
`WhoamiIsAdmin` / `WhoamiIsUser` variants are kept alongside the Perl
version for reference. Once the Perl watcher is verified on a kiosk,
the `.bat` files can be removed -- the Startup shortcut should be the
only entry point that actually runs.

---

## What you do NOT need to install

- **No CPAN modules.** `Win32::OLE`, `Time::HiRes`, `Getopt::Long`,
  `POSIX`, `Cwd`, `File::Basename` are all part of Strawberry Perl's
  default install.
- **No Cygwin / MSYS2 / WSL.** The script uses native Win32 APIs
  through `Win32::OLE`. Anything else (Cygwin Perl, WSL) would put
  Edge back into Session 0, which is exactly the bug the watcher was
  built to avoid.
- **No PATH gymnastics beyond the installer.** Strawberry Perl's
  installer is enough.
