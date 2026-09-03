# created by AI

param (
    [Parameter(Mandatory=$true)]
    [string]$baseUri,

    [Parameter(Mandatory=$true)]
    [string]$user,

    [Parameter(Mandatory=$true)]
    [string]$password,

    [Parameter(Mandatory=$true)]
    [string[]]$files
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Start upload process ($baseUri) ===" -ForegroundColor Cyan
Write-Host "User: $user" -ForegroundColor Cyan

# ignore certificate errors - as -k option in cURL
# needed e.g. if using self signed certificates wich are not in the trust list of the client
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# 1. login
$url = "${baseUri}/authenticate.cgi"
$randomTs = Get-Random -Minimum 1000 -Maximum 99999
# fill POST parameters with login data
$authBody = @{
    user     = $user
    password = $password
    _ts      = $randomTs
}
try {
	# using deprecated webClient because of compatilibity to Powershell 5.1
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
    
    # put POST data
    $authBody = "user=$([Uri]::EscapeDataString($user))&password=$([Uri]::EscapeDataString($password))&_ts=$randomTs"
    # send POST request 
    $responseString = $webClient.UploadString($url, "POST", $authBody)
    $response = ConvertFrom-Json $responseString

    if ($response.status -eq "ok") {
        $uuid = $response.uuid
    } else {
        Write-Error "login failed, status not ok ($responseString)"
        exit 1
    }
}
catch {
    Write-Error "Connection error: $_"
    exit 1
}

Write-Host "Authentication successful. Token received: $uuid" -ForegroundColor Green

# 2. send file by file
foreach ($file in $files) {
    Write-Host "----------------------------------------"
	if (-not $uuid) { Write-Error "Fehler: Keine UUID übergeben."; exit 1 }
	if (-not (Test-Path $file)) { Write-Error "Fehler: Datei '$file' existiert nicht."; exit 1 }

	$uploadUrlBase = "${baseUri}/uploader.cgi"
	$targetUploadUrl = "${uploadUrlBase}?do_upload=true&uuid=${uuid}"

	try {
		Write-Host "Upload file: $file" -ForegroundColor Yellow
		
		# using deprecated webClient because of compatilibity to Powershell 5.1
		$webClient = New-Object System.Net.WebClient
		# upload (similar to curl -F filename=@...)
		$responseBytes = $webClient.UploadFile($targetUploadUrl, "POST", $file)
		# server response
		$uploadResponse = [System.Text.Encoding]::ASCII.GetString($responseBytes)
		
		Write-Host "Upload successful: $(Split-Path $file -Leaf)" -ForegroundColor Green
	}
	catch {
		Write-Error "Error uploading $file : $_"
		exit 1
	}
}

# 3. end process
Write-Host "----------------------------------------"
Write-Host "End upload session..." -ForegroundColor Yellow

$closeUrl = "${baseUri}/uploader.cgi?end_upload=true&uuid=${uuid}"

try {
	# using deprecated webClient because of compatilibity to Powershell 5.1
    $webClient = New-Object System.Net.WebClient
    $closeResponseString = $webClient.DownloadString($closeUrl)
    $closeResponse = ConvertFrom-Json $closeResponseString
    
    if ($closeResponse.status -eq "ok") {
        Write-Host "Session ended. Status is ok." -ForegroundColor Green
    } else {
        Write-Host "Warning: session ended, but server status was: $($closeResponseString)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error ending session: $_" -ForegroundColor Red
    exit 1
}

Write-Host "========================================"
Write-Host "Process done." -ForegroundColor Cyan
