@echo off

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