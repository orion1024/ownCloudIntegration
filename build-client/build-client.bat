@echo off
setlocal

rem -------------------------------------------------
rem 	Build owncloud client 
rem Author : orion1024
rem Date : 2016
rem -------------------------------------------------

set BUILD_DIR=E:\client-build

rem Setting source dir
IF /I "%2"=="" (
	set SRC_DIR=%WORKSPACE%
) ELSE (
	set SRC_DIR=%2
)
	
IF NOT EXIST "%SRC_DIR%" (
	echo Sources not found : "%SRC_DIR%" does not exists
	exit 1
)

rem Purge old build data if any
IF EXIST %BUILD_DIR%	del /F /Q %BUILD_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

rem Building it
cmake -G "MinGW Makefiles" "%SRC_DIR%"
mingw32-make

endlocal