@echo off

set CUR_DIR=%~dp0

rem Launch the Sikuli script that will connect to jenkins

set SIKULI_PATH=E:\Sikuli
set SIKULI_CMD=runsikulix.cmd
set LOG_FILE=%~n0.log

set SIKULI_SCRIPT=enslavment.sikuli

set SIKULI_SCRIPT_FULL_TEMP=
set SIKULI_SCRIPT_FULL_FINAL=%SIKULI_SCRIPT_FULL_TEMP%

"%SIKULI_PATH%\%SIKULI_CMD%" -r "%CUR_DIR:\=\\%%SIKULI_SCRIPT%" -f "%CUR_DIR:\=\\%%LOG_FILE%" -- %COMPUTERNAME%

pause

