@echo off

if not "%~0"=="%~dp0.\%~nx0" (
    start /min cmd /c,"%~dp0.\%~nx0" %*
    exit
)

set my_name=%~n0
powershell -ExecutionPolicy RemoteSigned -File "./%my_name%.ps1"