$ErrorActionPreference = 'Stop'
$component = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $component 'fast-feedback.ps1'
$fixtures = Join-Path $PSScriptRoot 'fixtures'
$cases = @(
    @{ file='valid.json'; status='passed'; exit=0 },
    @{ file='invalid.json'; status='failed'; exit=1 },
    @{ file='valid.ps1'; status='passed'; exit=0 },
    @{ file='invalid.ps1'; status='failed'; exit=1 },
    @{ file='unsupported.txt'; status='skipped'; exit=0 }
)

foreach ($case in $cases) {
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Path (Join-Path $fixtures $case.file) -ProjectPath $fixtures
    $code = $LASTEXITCODE
    $result = $output | ConvertFrom-Json
    if ($code -ne $case.exit) { throw "$($case.file): expected exit $($case.exit), got $code." }
    if ($result.status -ne $case.status) { throw "$($case.file): expected $($case.status), got $($result.status)." }
    Write-Output "PASS: $($case.file) -> $($case.status)"
}
Write-Output 'Fast Feedback tests passed.'
