REM define CU as variable with value "input param. + 1"
set /a CU=%1+1
REM use value of CU as batch return value
exit /b %CU%
