@echo off

:loop
if exist "C:\Users\Miramar\Documents\scripts\show_maintenance.flag" (
    del "C:\Users\Miramar\Documents\scripts\show_maintenance.flag"
    call "C:\Users\Miramar\Documents\scripts\launchMAPage.bat"
)

timeout /t 5 /nobreak >nul
goto loop
