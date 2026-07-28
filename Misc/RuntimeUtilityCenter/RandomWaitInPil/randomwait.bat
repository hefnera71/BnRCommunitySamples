@echo off
REM define rand as variable with a random value between %1 and %2 values
REM %RANDOM% itself returns a number between 0 and 32767
set /a rand=%RANDOM% * %2 / 32768 + %1
REM wait x seconds
TIMEOUT %rand%
REM use value of rand as batch return value
exit /b %rand%
