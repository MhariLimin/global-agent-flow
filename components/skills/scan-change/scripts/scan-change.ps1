[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ProjectPath,
    [string]$ReportDirectory,
    [string]$ConfigurationPath,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
    $ConfigurationPath = Join-Path $projectRoot '.ai-workflow.json'
}
if ([string]::IsNullOrWhiteSpace($ReportDirectory)) {
    $ReportDirectory = Join-Path $projectRoot '.ai-workflow-reports\security'
}
if (-not (Test-Path -LiteralPath $ConfigurationPath -PathType Leaf)) {
    throw "Security scan configuration not found: $ConfigurationPath"
}

$configuration = Get-Content -LiteralPath $ConfigurationPath -Raw | ConvertFrom-Json
if ($configuration.version -ne 1) {
    throw "Unsupported configuration version: $($configuration.version)"
}
$checks = @($configuration.securityChecks)
if ($checks.Count -eq 0) {
    throw 'No securityChecks configured. Add explicit project-approved scanners.'
}

$allowedKinds = @('secret', 'dependency', 'sast', 'infrastructure', 'other')
$names = @{}
$results = @()

foreach ($check in $checks) {
    if ([string]::IsNullOrWhiteSpace($check.name) -or
        [string]::IsNullOrWhiteSpace($check.kind) -or
        [string]::IsNullOrWhiteSpace($check.command)) {
        throw 'Every security check requires non-empty name, kind, and command values.'
    }
    if ($names.ContainsKey($check.name)) { throw "Duplicate security check name: $($check.name)" }
    if ($allowedKinds -notcontains $check.kind) { throw "Unsupported security check kind: $($check.kind)" }
    $names[$check.name] = $true

    $started = Get-Date
    if ($DryRun) {
        $results += [pscustomobject]@{
            name=$check.name; kind=$check.kind; command=$check.command
            status='skipped'; exitCode=$null; durationMs=0
            detail='Dry run: command not executed.'
        }
        continue
    }

    if (-not (Get-Command $check.command -ErrorAction SilentlyContinue)) {
        $results += [pscustomobject]@{
            name=$check.name; kind=$check.kind; command=$check.command
            status='failed'; exitCode=127; durationMs=0
            detail='Executable not found. No scanner output captured.'
        }
        continue
    }

    # Security scanner output can contain matched secrets or source excerpts.
    # Discard both streams without loading them into this process or a report.
    & $check.command @($check.args) *> $null
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $duration = [int]((Get-Date) - $started).TotalMilliseconds
    $results += [pscustomobject]@{
        name=$check.name; kind=$check.kind; command=$check.command
        status=if ($exitCode -eq 0) { 'passed' } else { 'failed' }
        exitCode=$exitCode; durationMs=$duration
        detail='Scanner output suppressed and not stored.'
    }
}

$summary = [ordered]@{
    passed=@($results | Where-Object status -eq 'passed').Count
    failed=@($results | Where-Object status -eq 'failed').Count
    skipped=@($results | Where-Object status -eq 'skipped').Count
    total=$results.Count
}
$outcome = if ($DryRun) { 'planned' } elseif ($summary.failed -gt 0) { 'failed' } else { 'passed' }
$report = [ordered]@{
    schemaVersion=1
    generatedAt=(Get-Date).ToUniversalTime().ToString('o')
    project=[ordered]@{ name=(Split-Path -Leaf $projectRoot); path=$projectRoot }
    dryRun=[bool]$DryRun
    outputPolicy='suppressed-not-stored'
    checks=$results
    summary=$summary
    outcome=$outcome
}

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null
$jsonPath = Join-Path $ReportDirectory 'security-report.json'
$markdownPath = Join-Path $ReportDirectory 'security-report.md'
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding utf8

$markdown = @(
    '# Security Scan Report', '',
    "- Outcome: **$outcome**",
    "- Generated: $($report.generatedAt)",
    '- Scanner output: **suppressed and not stored**', '',
    '| Check | Kind | Status | Exit | Duration (ms) |',
    '| --- | --- | --- | ---: | ---: |'
)
foreach ($result in $results) {
    $markdown += "| $($result.name) | $($result.kind) | $($result.status) | $($result.exitCode) | $($result.durationMs) |"
}
$markdown += @('', '> Run a failed scanner through its approved secure interface to inspect details. Never paste secret values into an AI conversation.')
$markdown | Set-Content -LiteralPath $markdownPath -Encoding utf8

Write-Output "Report: $markdownPath"
if ($outcome -eq 'failed') { exit 1 }
exit 0
