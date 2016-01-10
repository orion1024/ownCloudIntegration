@echo off
setlocal

rem -------------------------------------------------
rem 	Launch Sikuli script to connect to jenkins 
rem Author : orion1024
rem Date : 2016
rem -------------------------------------------------

set CUR_DIR=%~dp0
set LOG_FILE=%CUR_DIR%%~n0.log
cd %CUR_DIR%

call connectToJenkins.bat >> %LOG_FILE%

endlocal