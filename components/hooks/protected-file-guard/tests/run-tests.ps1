$ErrorActionPreference = 'Stop'
$component = Split-Path -Parent $PSScriptRoot
$guard = Join-Path $component 'guard-protected-file.ps1'
$cases = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'cases.json') -Raw | ConvertFrom-Json

foreach ($case in $cases) {
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $guard -Path $case.path -Mode $case.mode
    $exitCode = $LASTEXITCODE
    $result = $output | ConvertFrom-Json
    if ($exitCode -ne $case.exitCode) { throw "$($case.name): expected exit $($case.exitCode), got $exitCode." }
    if ($result.decision -ne $case.decision) { throw "$($case.name): expected $($case.decision), got $($result.decision)." }
    Write-Output "PASS: $($case.name)"
}

$eventFile = Join-Path $PSScriptRoot 'fixtures\claude-edit-event.json'
$eventOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $guard -EventFile $eventFile -Mode audit
$eventResult = $eventOutput | ConvertFrom-Json
if ($eventResult.decision -ne 'would-deny') { throw 'Event-path extraction failed.' }
Write-Output 'PASS: structured event path'
Write-Output 'Protected File Guard tests passed.'
