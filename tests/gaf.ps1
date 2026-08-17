$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $repository 'scripts\gaf.ps1'
$testHome = Join-Path $repository 'artifacts\gaf-tests\user-home'

if (Test-Path -LiteralPath $testHome) {
    Remove-Item -LiteralPath $testHome -Recurse -Force
}

& $runner install -Provider all -UserHome $testHome
if ($LASTEXITCODE -notin @(0, $null)) { throw "gaf install failed: $LASTEXITCODE" }

$components = @(
    'verify-change', 'debug-systematically', 'review-change',
    'review-security', 'prepare-change', 'scan-change', 'dev-flow'
)
foreach ($providerRoot in @('.agents\skills', '.claude\skills')) {
    foreach ($component in $components) {
        $destination = Join-Path $testHome "$providerRoot\$component"
        if (-not (Test-Path -LiteralPath (Join-Path $destination 'SKILL.md'))) {
            throw "Missing installed skill: $providerRoot/$component"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $destination '.gaf-managed.json'))) {
            throw "Missing managed marker: $providerRoot/$component"
        }
    }
}
Write-Output 'PASS: gaf install'

$managedSkill = Join-Path $testHome '.agents\skills\dev-flow\SKILL.md'
Set-Content -LiteralPath $managedSkill -Value 'stale'
& $runner sync -Provider codex -UserHome $testHome
if ((Get-Content -LiteralPath $managedSkill -Raw) -notmatch 'name: dev-flow') {
    throw 'gaf sync did not restore canonical content.'
}
Write-Output 'PASS: gaf sync'

$unmanaged = Join-Path $testHome '.agents\skills\unmanaged-example'
New-Item -ItemType Directory -Path $unmanaged -Force | Out-Null
Set-Content -LiteralPath (Join-Path $unmanaged 'SKILL.md') -Value 'unmanaged'

$status = @(& $runner status -Provider codex -UserHome $testHome)
if ($status -notcontains 'codex/dev-flow: managed') { throw 'gaf status did not report managed skill.' }
Write-Output 'PASS: gaf status'

# Simulate a name collision and confirm install refuses to overwrite it.
$collision = Join-Path $testHome '.agents\skills\verify-change'
Remove-Item -LiteralPath (Join-Path $collision '.gaf-managed.json') -Force
$failedSafely = $false
try {
    & $runner sync -Provider codex -UserHome $testHome
} catch {
    $failedSafely = $_.Exception.Message -match 'Refusing to overwrite unmanaged skill'
}
if (-not $failedSafely) { throw 'gaf sync did not protect an unmanaged skill collision.' }
Write-Output 'PASS: gaf unmanaged collision guard'
