:: gcc.bat
:: v0.5
:: Compile optimized for speed EXE file using gcda profile

@ECHO OFF
REM Compile EXE file with gcda optimization profile
::SET line=gcc.exe -O4 -flto -march=native -mtune=native -mthreads -mmmx -msse -msse2 -msse3 -m3dnow -Wall -fmessage-length=0 -MMD -MP -MF"%~n1.d" -MT"%~n1.d" -o "%~n1.exe"
SET line=gcc.exe -O3 -march=native -mtune=native -mthreads -Wall -fmessage-length=0 -MMD -MP -MF"%~n1.d" -MT"%~n1.d" -o "%~n1.exe"
IF EXIST "%~n1.gcda" (
ECHO.
ECHO Step 2/2:
ECHO Compile optimized "%~n1.exe" using gcda profile.
ECHO.
%line% -fprofile-use "%~n1.c" 
DEL "%~n1.gcda"
DEL "%~n1.d" ) ELSE (
ECHO.
ECHO Step 1/2:
ECHO Run "%~n1.exe" for generate gcda profile, then run the complilation again.
ECHO.
%line% -fprofile-generate "%~n1.c" )