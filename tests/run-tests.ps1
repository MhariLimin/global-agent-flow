$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $repository 'scripts\verify-change.ps1'
$artifacts = Join-Path $repository 'artifacts\tests'

function Assert-Equal($Expected, $Actual, [string]$Message) {
    if ($Expected -ne $Actual) { throw "$Message Expected '$Expected', got '$Actual'." }
}

function Run-Case([string]$Name, [int]$ExpectedExit, [string]$ExpectedOutcome, [string]$ExpectedStatus, [switch]$DryRun) {
    $fixture = Join-Path $PSScriptRoot "fixtures\$Name"
    $reportDirectory = Join-Path $artifacts $Name
    $runnerArguments = @('-NoProfile', '-File', $runner, '-ProjectPath', $fixture, '-ReportDirectory', $reportDirectory)
    if ($DryRun) { $runnerArguments += '-DryRun' }
    & powershell @runnerArguments
    $actualExit = $LASTEXITCODE
    $report = Get-Content -LiteralPath (Join-Path $reportDirectory 'quality-report.json') -Raw | ConvertFrom-Json
    Assert-Equal $ExpectedExit $actualExit "$Name exit code."
    Assert-Equal $ExpectedOutcome $report.outcome "$Name outcome."
    Assert-Equal $ExpectedStatus $report.checks[0].status "$Name status."
    Assert-Equal 1 $report.summary.total "$Name total."
    Write-Output "PASS: $Name"
}

Run-Case 'passing' 0 'passed' 'passed'
Run-Case 'failing' 1 'failed' 'failed'
Run-Case 'missing-tool' 1 'failed' 'failed'
Run-Case 'passing' 0 'planned' 'skipped' -DryRun

$securityScanTests = Join-Path $repository 'tests\scan-change.ps1'
& $securityScanTests

$gafTests = Join-Path $repository 'tests\gaf.ps1'
& $gafTests

$skill = Join-Path $repository 'components\skills\verify-change\SKILL.md'
$content = Get-Content -LiteralPath $skill -Raw
if ($content -notmatch '(?s)^---\s+name: verify-change\s+description: .+?\s+---') {
    throw 'Skill frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'Skill contains unresolved TODO markers.' }
Write-Output 'PASS: skill-frontmatter'

$hookTests = Join-Path $repository 'components\hooks\protected-file-guard\tests\run-tests.ps1'
& powershell -NoProfile -ExecutionPolicy Bypass -File $hookTests
if ($LASTEXITCODE -ne 0) { throw "Protected File Guard tests failed with exit code $LASTEXITCODE." }

$fastFeedbackTests = Join-Path $repository 'components\hooks\fast-feedback\tests\run-tests.ps1'
& powershell -NoProfile -ExecutionPolicy Bypass -File $fastFeedbackTests
if ($LASTEXITCODE -ne 0) { throw "Fast Feedback tests failed with exit code $LASTEXITCODE." }

$debugSkillTests = Join-Path $repository 'tests\skill-contracts\debug-systematically.ps1'
& $debugSkillTests

$reviewSkillTests = Join-Path $repository 'tests\skill-contracts\review-change.ps1'
& $reviewSkillTests

$securityReviewSkillTests = Join-Path $repository 'tests\skill-contracts\review-security.ps1'
& $securityReviewSkillTests

$prepareSkillTests = Join-Path $repository 'tests\skill-contracts\prepare-change.ps1'
& $prepareSkillTests

$devFlowTests = Join-Path $repository 'tests\skill-contracts\dev-flow.ps1'
& $devFlowTests
Write-Output 'All tests passed.'
