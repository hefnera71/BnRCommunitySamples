:: Created by AI

@echo off
setlocal enabledelayedexpansion

:: 1. Read input parameters (%1 = Base URI, %2 = Username, %3 = Password, %4 = File path)
set "BASE_URI=%~1"
set "USERNAME=%~2"
set "PASSWORD=%~3"
set "FILE_PATH=%~4"

:: 2. Check if all four mandatory parameters were provided
if "%BASE_URI%"=="" goto :usage
if "%USERNAME%"=="" goto :usage
if "%PASSWORD%"=="" goto :usage
if "%FILE_PATH%"=="" goto :usage

:: 3. Verify if the target file actually exists locally
if not exist "%FILE_PATH%" (
    echo Error: The file "%FILE_PATH%" was not found.
    goto :eof
)

:: 4. Remove trailing slash from Base URI if present to prevent double slashes
if "%BASE_URI:~-1%"=="/" set "BASE_URI=%BASE_URI:~0,-1%"

:: 5. Define full API endpoint URLs
set "AUTH_URL=%BASE_URI%/authenticate.cgi"
set "UPLOAD_URL=%BASE_URI%/uploader.cgi"

:: 6. Generate a random number for the _ts parameter
set "TS_RANDOM=%RANDOM%"

echo ===================================================
echo 1. AUTHENTICATION
echo ===================================================
set "response_auth="
for /f "delims=" %%i in ('curl -sS -k -X POST -d "user=%USERNAME%" -d "password=%PASSWORD%" -d "_ts=%TS_RANDOM%" -H "Content-Type: application/x-www-form-urlencoded" "%AUTH_URL%" 2^>nul') do (
    set "response_auth=%%i"
)
echo Response: !response_auth!
echo.

:: 7. Extract the 32-character UUID from the authentication response
set "uuid="
if defined response_auth (
    set "temp_str=!response_auth:*uuid:"=!"
    set "uuid=!temp_str:~0,32!"
)

:: 8. Second Stage: Proceed with upload if UUID extraction succeeded
if defined uuid (
    echo ===================================================
    echo 2. FILE UPLOAD
    echo ===================================================
    echo Starting upload of: "%FILE_PATH%"...
    
    set "response_upload="
    for /f "delims=" %%i in ('curl -sS -k -X POST -F "filename=@%FILE_PATH%" -H "Content-Type: multipart/form-data" "!UPLOAD_URL!?do_upload=true&uuid=!uuid!" 2^>nul') do (
        set "response_upload=%%i"
    )
    echo Response: !response_upload!
    echo.
    
    echo ===================================================
    echo 3. TERMINATE CONNECTION
    echo ===================================================
    echo Closing session...
    
    set "response_end="
    for /f "delims=" %%i in ('curl -sS -k -X GET "!UPLOAD_URL!?end_upload=true&uuid=!uuid!" 2^>nul') do (
        set "response_end=%%i"
    )
    echo Response: !response_end!
    echo ===================================================
) else (
    echo Error: Could not extract UUID. Login failed?
)
goto :eof

:: Help/Usage screen for invalid parameters
:usage
echo Error: Invalid parameters.
echo Usage: %~nx0 "[BASE_URI]" "[USERNAME]" "[PASSWORD]" "[FILE_PATH]"
echo Example: %~nx0 "https://192.168.168.178" "User3" "Password3" "c:\test\testdata.txt"
pause
:eof