# Busca JSON no AWS Secrets Manager e grava .env (Windows).
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $Root

function Resolve-SecretId {
  if ($env:GOAB_AWS_SECRET_ID) { return $env:GOAB_AWS_SECRET_ID.Trim() }
  $idFile = Join-Path $Root ".goab-aws-secret-id"
  if (Test-Path $idFile) {
    return (Get-Content $idFile -Raw).Trim()
  }
  return "dev/$((Split-Path $Root -Leaf))"
}

function Format-EnvValue([string]$Key, $Value) {
  if ($null -eq $Value) { return $null }
  if ($Value -is [System.Collections.IDictionary] -or $Value -is [Array]) {
    $json = $Value | ConvertTo-Json -Compress -Depth 100
    return "${Key}=${json}"
  }
  $text = [string]$Value
  $trim = $text.Trim()
  if ($trim.StartsWith("{") -or $trim.StartsWith("[")) {
    try {
      $parsed = $trim | ConvertFrom-Json
      $json = $parsed | ConvertTo-Json -Compress -Depth 100
      return "${Key}=${json}"
    } catch { }
  }
  if ($text -match "[`n`r`"#]") {
    $escaped = $text -replace '\\', '\\\\' -replace '"', '\"'
    return "${Key}=""${escaped}"""
  }
  return "${Key}=${text}"
}

$Region = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
$EnvFile = if ($env:GOAB_ENV_FILE) { $env:GOAB_ENV_FILE } else { ".env" }
$SecretId = Resolve-SecretId
$Dest = Join-Path $Root $EnvFile

Write-Host "===> AWS Secrets Manager"
Write-Host "     secret-id: $SecretId"
Write-Host "     region:    $Region"

$awsOutput = aws secretsmanager get-secret-value `
  --secret-id $SecretId `
  --region $Region `
  --query SecretString `
  --output text 2>&1

if ($LASTEXITCODE -ne 0) {
  $msg = "$awsOutput"
  if ($msg -match 'ResourceNotFound|SecretNotFound|can''t find|not find the specified secret') {
    Write-Host "⏭️  Secret não encontrado ($SecretId) — .env não alterado"
    Write-Host "GOAB_FETCH_ENV_STATUS=skipped"
    exit 0
  }
  throw $msg
}

$raw = $awsOutput
if (-not $raw) {
  Write-Host "⏭️  Secret vazio ($SecretId) — .env não alterado"
  Write-Host "GOAB_FETCH_ENV_STATUS=skipped"
  exit 0
}

$data = $raw | ConvertFrom-Json
if (-not ($data -is [PSCustomObject])) {
  throw "Secret deve ser JSON objeto (chave → valor)."
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Gerado por scripts/fetch-env ($(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'))")
$lines.Add("# secret-id: $SecretId")
$lines.Add("")

$keys = @()
foreach ($prop in $data.PSObject.Properties) {
  if ($null -eq $prop.Value -or "$($prop.Value)" -eq "") { continue }
  $line = Format-EnvValue $prop.Name $prop.Value
  if ($line) {
    $lines.Add($line)
    $keys += $prop.Name
  }
}

Set-Content -Path $Dest -Value $lines -Encoding utf8
Write-Host "===> $Dest atualizado"
Write-Host "===> Chaves: $($keys -join ', ')"
