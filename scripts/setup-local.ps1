param(
    [string]$DbName = "Cello_Zorg",
    [string]$DbUser = "simulation_user",
    [string]$DbHost = "127.0.0.1",
    [int]$DbPort = 3306,
    [string]$DbAdminUser = "",
    [string]$DbAdminPassword = "",
    [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$ConfigFile = Join-Path $RootDir "config\local.php"
$SchemaFile = Join-Path $RootDir "database\schema.sql"

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function New-RandomHex {
    param([int]$Bytes)
    $buffer = New-Object byte[] $Bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($buffer)
    return -join ($buffer | ForEach-Object { $_.ToString("x2") })
}

function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    if (-not (Test-Command "winget")) {
        throw "winget is not available. Install $DisplayName manually, then rerun this script with -SkipInstall."
    }

    Write-Host "Installing $DisplayName..."
    winget install --id $PackageId --source winget --accept-package-agreements --accept-source-agreements
}

function Get-PhpClient {
    $php = Get-Command "php" -ErrorAction SilentlyContinue
    if ($php) {
        return $php.Source
    }

    $candidates = @(
        "$env:ProgramFiles\PHP*\php.exe",
        "${env:ProgramFiles(x86)}\PHP*\php.exe",
        "C:\php\php.exe",
        "C:\tools\php*\php.exe"
    )

    foreach ($candidate in $candidates) {
        $match = Get-ChildItem -Path $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) {
            return $match.FullName
        }
    }

    return $null
}

function Get-MariaDbClient {
    $client = Get-Command "mariadb" -ErrorAction SilentlyContinue
    if ($client) {
        return $client.Source
    }

    $mysql = Get-Command "mysql" -ErrorAction SilentlyContinue
    if ($mysql) {
        return $mysql.Source
    }

    $candidates = @(
        "$env:ProgramFiles\MariaDB*\bin\mariadb.exe",
        "$env:ProgramFiles\MariaDB*\bin\mysql.exe",
        "${env:ProgramFiles(x86)}\MariaDB*\bin\mariadb.exe",
        "${env:ProgramFiles(x86)}\MariaDB*\bin\mysql.exe"
    )

    foreach ($candidate in $candidates) {
        $match = Get-ChildItem -Path $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) {
            return $match.FullName
        }
    }

    return $null
}

function Start-MariaDbService {
    $service = Get-Service -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "MariaDB*" -or $_.DisplayName -like "MariaDB*" -or $_.Name -like "MySQL*" } |
        Select-Object -First 1

    if (-not $service) {
        Write-Host "No MariaDB/MySQL Windows service was found. If MariaDB is installed, start it manually."
        return
    }

    if ($service.Status -ne "Running") {
        Write-Host "Starting $($service.Name)..."
        Start-Service -Name $service.Name
    }
}

function Invoke-MariaDb {
    param(
        [string]$Client,
        [string]$User,
        [string]$Password,
        [string]$Database = "",
        [string]$Sql = ""
    )

    $arguments = @(
        "--protocol=TCP",
        "-h", $DbHost,
        "-P", "$DbPort",
        "-u", $User
    )

    if ($Password -ne "") {
        $arguments += "--password=$Password"
    }

    if ($Database -ne "") {
        $arguments += $Database
    }

    if ($Sql -ne "") {
        $arguments += @("-e", $Sql)
    }

    & $Client @arguments
}

function Test-MariaDbLogin {
    param(
        [string]$Client,
        [string]$User,
        [string]$Password
    )

    try {
        Invoke-MariaDb -Client $Client -User $User -Password $Password -Sql "SELECT 1;" *> $null
        return $true
    } catch {
        return $false
    }
}

if (-not $SkipInstall) {
    if (-not (Get-PhpClient)) {
        Install-WingetPackage -PackageId "PHP.PHP" -DisplayName "PHP"
    }

    if (-not (Get-MariaDbClient)) {
        Install-WingetPackage -PackageId "MariaDB.Server" -DisplayName "MariaDB Server"
    }
}

$MariaDbClient = Get-MariaDbClient
if (-not $MariaDbClient) {
    throw "MariaDB client was not found. Install MariaDB Server, then rerun this script."
}

$PhpClient = Get-PhpClient
if (-not $PhpClient) {
    throw "PHP was not found. Install PHP, then rerun this script."
}

Start-MariaDbService

if ($DbAdminUser -eq "") {
    $candidateUsers = @($env:USERNAME, "root")
    foreach ($candidate in $candidateUsers) {
        if (Test-MariaDbLogin -Client $MariaDbClient -User $candidate -Password "") {
            $DbAdminUser = $candidate
            break
        }
    }
}

if ($DbAdminUser -eq "") {
    throw "Could not connect to MariaDB. Rerun with -DbAdminUser root -DbAdminPassword '<password>'."
}

if (-not (Test-MariaDbLogin -Client $MariaDbClient -User $DbAdminUser -Password $DbAdminPassword)) {
    throw "Could not connect to MariaDB as '$DbAdminUser'. Rerun with the correct -DbAdminPassword."
}

if (Test-Path $ConfigFile) {
    $DbPassword = & $PhpClient -r '$config = require $argv[1]; echo $config["db"]["password"] ?? "";' $ConfigFile
    $HashSecret = & $PhpClient -r '$config = require $argv[1]; echo $config["app"]["hash_secret"] ?? "";' $ConfigFile
} else {
    $DbPassword = New-RandomHex -Bytes 16
    $HashSecret = New-RandomHex -Bytes 32
}

if ($DbPassword -eq "") {
    $DbPassword = New-RandomHex -Bytes 16
}

if ($HashSecret -eq "") {
    $HashSecret = New-RandomHex -Bytes 32
}

Write-Host "Creating database and app user..."
$setupSql = @"
CREATE DATABASE IF NOT EXISTS ``$DbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DbUser'@'localhost' IDENTIFIED BY '$DbPassword';
CREATE USER IF NOT EXISTS '$DbUser'@'127.0.0.1' IDENTIFIED BY '$DbPassword';
ALTER USER '$DbUser'@'localhost' IDENTIFIED BY '$DbPassword';
ALTER USER '$DbUser'@'127.0.0.1' IDENTIFIED BY '$DbPassword';
GRANT INSERT, SELECT ON ``$DbName``.* TO '$DbUser'@'localhost';
GRANT INSERT, SELECT ON ``$DbName``.* TO '$DbUser'@'127.0.0.1';
FLUSH PRIVILEGES;
"@

Invoke-MariaDb -Client $MariaDbClient -User $DbAdminUser -Password $DbAdminPassword -Sql $setupSql

Write-Host "Creating tables..."
$schemaArguments = @(
    "--protocol=TCP",
    "-h", $DbHost,
    "-P", "$DbPort",
    "-u", $DbAdminUser
)

if ($DbAdminPassword -ne "") {
    $schemaArguments += "--password=$DbAdminPassword"
}

$schemaArguments += $DbName
Get-Content -Raw $SchemaFile | & $MariaDbClient @schemaArguments

$config = @"
<?php

return [
    'db' => [
        'host' => '$DbHost',
        'port' => $DbPort,
        'name' => '$DbName',
        'user' => '$DbUser',
        'password' => '$DbPassword',
        'charset' => 'utf8mb4',
    ],
    'app' => [
        'hash_secret' => '$HashSecret',
    ],
];
"@

Set-Content -Path $ConfigFile -Value $config -Encoding UTF8

Write-Host ""
Write-Host "Local setup complete."
Write-Host "Run: .\scripts\run-local.ps1"
Write-Host "Open: http://127.0.0.1:8000/index.php"
