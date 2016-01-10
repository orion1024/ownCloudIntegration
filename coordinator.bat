@echo off
setlocal
rem ----------------------------------------------------------
rem 	Executes a set of scripts based on given arguments
rem		and the content of the script folders.
rem Author : orion1024
rem Date : 2016
rem ----------------------------------------------------------

set CUR_DIR=%~dp0
set LOG_FILE=%CUR_DIR%%~n0.log
cd %CUR_DIR%

rem The first argument is the set of scripts the caller wants us to execute
call %1\%1.bat >> %LOG_FILE%


endlocal
