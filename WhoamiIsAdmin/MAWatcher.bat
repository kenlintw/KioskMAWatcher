@echo off

:loop
if exist "C:\Users\admin\Documents\scripts\show_maintenance.flag" (
    del "C:\Users\admin\Documents\scripts\show_maintenance.flag"
    call "C:\Users\admin\Documents\scripts\launchMAPage.bat"
)

timeout /t 50 /nobreak >nul
goto loop
