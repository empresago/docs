# Entry point Windows (PowerShell) → script específico do SO.
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
& (Join-Path $Root "scripts\install-deps\win.ps1")
