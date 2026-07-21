@echo off

:loop
if exist "C:\Users\User\Documents\scripts\show_maintenance.flag" (
    del "C:\Users\User\Documents\scripts\show_maintenance.flag"
    call "C:\Users\User\Documents\scripts\launchMAPage.bat"
)

timeout /t 50 /nobreak >nul
goto loop
