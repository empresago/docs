# Instala dependências npm no Windows (PowerShell).
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $Root

$AwsRegion = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
$Domain = if ($env:CODEARTIFACT_DOMAIN) { $env:CODEARTIFACT_DOMAIN } else { "goab-core" }
$Owner = if ($env:CODEARTIFACT_DOMAIN_OWNER) { $env:CODEARTIFACT_DOMAIN_OWNER } else { "905418038614" }
$Repository = if ($env:CODEARTIFACT_REPOSITORY) { $env:CODEARTIFACT_REPOSITORY } else { "goab-repo" }

Write-Host "===> CodeArtifact login (npm)"
aws codeartifact login --tool npm `
  --domain $Domain `
  --domain-owner $Owner `
  --repository $Repository `
  --region $AwsRegion

if (Test-Path "package-lock.json") {
  $installExtra = if ($env:GOAB_INSTALL_ARGS) { $env:GOAB_INSTALL_ARGS } else { "" }
  Write-Host "===> npm ci $installExtra"
  npm ci @($installExtra -split '\s+')
} else {
  $installExtra = if ($env:GOAB_INSTALL_ARGS) { $env:GOAB_INSTALL_ARGS } else { "" }
  Write-Host "===> package-lock.json ausente; npm install $installExtra"
  npm install @($installExtra -split '\s+')
}

Write-Host "===> Dependências instaladas"
