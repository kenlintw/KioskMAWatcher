@echo off

rem Do not wrap the Edge path in an "if ... ( )" block using %VAR% expansion.
rem "C:\Program Files (x86)\..." contains a ")" that breaks cmd.exe's block
rem parser when expanded inside a parenthesized if/for body, aborting the
rem whole batch (caused a real outage on kiosk03 on 2026-07-17). If an
rem existence check is ever needed, use "if not exist ... goto" instead,
rem or enable delayed expansion and reference the path as !VAR!.

echo [%date% %time%] Task started >> C:\Users\Miramar\Documents\scripts\launchMAPage.log

"C:\ITKiosk\Tool\KillMainApModule.exe" >> C:\Users\Miramar\Documents\scripts\launchMAPage.log 2>&1

timeout /t 2 /nobreak >nul

taskkill /IM msedge.exe /F >nul 2>&1
timeout /t 1 /nobreak >nul

start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ^
    --kiosk file:///C:/MAPage/KioskMA.html ^
    --edge-kiosk-type=fullscreen ^
    --no-first-run

timeout /t 3 /nobreak >nul

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ws = New-Object -ComObject WScript.Shell; $ws.AppActivate('Edge') | Out-Null"

exit