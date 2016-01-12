@echo off

cd E:\client-build

cmake -G "MinGW Makefiles" ../jenkins/client
mingw32-make

pause