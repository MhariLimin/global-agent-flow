$ErrorActionPreference = 'Stop'
$eventJson = [Console]::In.ReadToEnd()
$runner = Join-Path $PSScriptRoot 'fast-feedback.ps1'
$output = & $runner -EventJson $eventJson
$code = $LASTEXITCODE
if ($code -ne 0) {
    $output | Write-Error
    exit 2
}
$output
exit 0
