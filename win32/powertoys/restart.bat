REM @echo off
taskkill /f /im PowerToys.exe
start "PowerToys" "C:\Users\%USERNAME%\AppData\Local\PowerToys\PowerToys.exe"
REM exit
