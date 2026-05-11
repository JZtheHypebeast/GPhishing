param(
    [string]$HostName = "127.0.0.1",
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot

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

$PhpClient = Get-PhpClient
if (-not $PhpClient) {
    throw "PHP was not found. Run .\scripts\setup-local.ps1 first."
}

Set-Location $RootDir

Write-Host "Starting PHP server at http://${HostName}:$Port/index.php"
& $PhpClient -S "${HostName}:$Port"
