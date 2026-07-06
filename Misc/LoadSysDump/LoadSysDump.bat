@echo off

REM cmd line parameter %1 = PLC URL, e.g. https://192.168.168.134
set _URL=%1
if [%1]==[] goto LABEL_USAGE
REM cmd line parameter %2 = path and name of uploaded module, e.g. ./sysdump.tar.gz
set _FN=%2
if [%2]==[] set _FN=./sysdump.tar.gz
REM cmd line parameter %3 = create system dump with or without data files 1=with data files, 0=without data files
set _DF=%3
if [%3]==[] set _DF=0
REM cmd line parameter %4 = use tar to perform a simple integrity check of the download 0= don't check, 1=check
set _USETAR=%4
if [%4]==[] set _USETAR=0

REM start creating the system dump on the PLC
echo *** trigger system dump creation on PLC ***
start /wait /i /min curl.exe "%_URL%/sdm/svg.cgi?type=systemdump&action=start&datafile=%_DF%&size=1" -H "Accept: */*" -H "User-Agent: curl/loadsysdump" -H "Connection: keep-alive" --insecure
echo %ERRORLEVEL%
IF %ERRORLEVEL% geq 1 goto LABEL_ERROR

REM download the system dump from PLC
echo *** download system dump to PC ***
start /wait /i /min curl.exe "%_URL%/sdm/cgiFileLoop.cgi?type=256&module=Sysdump" -H "Accept: */*" -H "User-Agent: curl/loadsysdump" -H "Connection: keep-alive" --insecure --output %_FN% 
echo %ERRORLEVEL%
REM -> do not exit here on errorlevel > 0 !!!
REM --> sometimes curl reports error 56, but everything worked as expected!? Haven't found the reason yet

REM step 3: delete the system dump on the PLC
echo *** delete system dump on PLC ***
start /wait /i /min curl.exe "%_URL%/sdm/svg.cgi?type=systemdump&action=delete&param=Sysdump&size=1" -H "Accept: */*" -H "User-Agent: curl/loadsysdump" -H "Connection: keep-alive" --insecure
echo %ERRORLEVEL%
IF %ERRORLEVEL% geq 1 goto LABEL_ERROR

REM step 4: do some simple check - is it a tar.gz file or not?
set _TEMPFILE=%TEMP%\loadsysdump.temp.tar.out
set _ZERO=0
if %_USETAR% equ 1 (
	echo *** check download integrity ***
	REM try to get archive list stored into a temporary file - this will fail if it's not a tar.gz file
	tar -tvzf %_FN% > %_TEMPFILE%
	REM if tar command failed, the temporary file will have length 0
	for %%i in (%_TEMPFILE%) do if %%~zi==0 set _ZERO=1
	REM remove temp file
	del %_TEMPFILE%
)
if %_USETAR% equ 1 echo %_ZERO%

REM evaluate step 4 result
if %_ZERO% equ 1 (
	echo E: Error from integrity check: Maybe wrong URL used? 
	REM delete file as integrity is not given
	del %_FN%
	REM exit with errorlevel 2 if step 4 failed
	exit /b 2
)
REM	exit with errorlevel 0
exit /b 0

REM exit with curl errorlevel 
:LABEL_ERROR
echo E: Error from curl: %ERRORLEVEL% - Maybe wrong URL used?
exit /b %ERRORLEVEL%

REM when used without parameters, print out some info and exit with errorlevel 1
:LABEL_USAGE
echo Usage: LoadSysDump.bat [URL of PLC] [PATH TO FILE] [SYSDUMP W/O DATA FILES {0 or 1}] [SIMPLE INTEGRITY CHECK {0 or 1}]
echo Example: LoadSysDump.bat https://192.168.168.134 c:\temp\sysdump.tar.gz 1 1
echo Requirements: SDM has to be enabled in the PLC to use this function
echo Information: this batch is not able to detect if a HTTP response was really sent from a PLC.
exit /b 1 

