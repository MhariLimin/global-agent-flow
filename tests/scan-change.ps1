$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $repository 'scripts\scan-change.ps1'
$artifacts = Join-Path $repository 'artifacts\security-tests'

function Assert-Equal($Expected, $Actual, [string]$Message) {
    if ($Expected -ne $Actual) { throw "$Message Expected '$Expected', got '$Actual'." }
}

function Run-Case([string]$Name, [int]$ExpectedExit, [string]$ExpectedOutcome, [string]$ExpectedStatus, [switch]$DryRun) {
    $fixture = Join-Path $PSScriptRoot "fixtures\$Name"
    $reportDirectory = Join-Path $artifacts $Name
    $arguments = @('-NoProfile', '-File', $runner, '-ProjectPath', $fixture, '-ReportDirectory', $reportDirectory)
    if ($DryRun) { $arguments += '-DryRun' }
    & powershell @arguments
    $actualExit = $LASTEXITCODE
    $jsonPath = Join-Path $reportDirectory 'security-report.json'
    $raw = Get-Content -LiteralPath $jsonPath -Raw
    $report = $raw | ConvertFrom-Json
    Assert-Equal $ExpectedExit $actualExit "$Name exit code."
    Assert-Equal $ExpectedOutcome $report.outcome "$Name outcome."
    Assert-Equal $ExpectedStatus $report.checks[0].status "$Name status."
    Assert-Equal 'suppressed-not-stored' $report.outputPolicy "$Name output policy."
    if ($raw -match 'sensitive finding') { throw "$Name report captured scanner output." }
    Write-Output "PASS: security $Name"
}

Run-Case 'passing' 0 'passed' 'passed'
Run-Case 'failing' 1 'failed' 'failed'
Run-Case 'missing-tool' 1 'failed' 'failed'
Run-Case 'passing' 0 'planned' 'skipped' -DryRun

$skillRoot = Join-Path $repository 'components\skills\scan-change'
$content = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw
if ($content -notmatch '(?s)^---\s+name: scan-change\s+description: .+?\s+---') {
    throw 'scan-change frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'scan-change contains unresolved TODO markers.' }
foreach ($required in @('references\project-configuration.md', 'references\report-contract.md', 'agents\openai.yaml')) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $required))) { throw "scan-change is missing $required." }
}
Write-Output 'PASS: scan-change contract'
