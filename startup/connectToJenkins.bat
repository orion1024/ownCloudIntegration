@echo off
setlocal

rem -------------------------------------------------
rem 	Launch Sikuli script to connect to jenkins 
rem Author : orion1024
rem Date : 2016
rem -------------------------------------------------

set CUR_DIR=%~dp0
set LOG_FILE=%CUR_DIR%%~n0.log

rem Sikuli setup
set SIKULI_PATH=E:\Sikuli
set SIKULI_CMD=runsikulix.cmd
set LOG_FILE=%~n0.log

rem Folder containing the script and the images
set SIKULI_SCRIPT=enslavment.sikuli

rem Used by Sikuli script
set SLAVE_NAME=%COMPUTERNAME%

"%SIKULI_PATH%\%SIKULI_CMD%" -r "%CUR_DIR:\=\\%%SIKULI_SCRIPT%" -f "%CUR_DIR:\=\\%%LOG_FILE%"

endlocal

