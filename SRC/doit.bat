@echo off
set OLDPATH=%PATH%

set TC=\TOOLS\TURBOC20\
REM set INCLUDE=%TC%\INCLUDE
REM set LIB=%TC%\LIB
set PATH=%TC%

make

set PATH=%OLDPATH%
set OLDPATH=
