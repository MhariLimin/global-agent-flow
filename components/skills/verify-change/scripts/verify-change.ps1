[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ProjectPath,
    [string]$ReportDirectory,
    [string]$ConfigurationPath,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
if ([string]::IsNullOrWhiteSpace($ReportDirectory)) {
    $ReportDirectory = Join-Path $projectRoot '.ai-workflow-reports'
}
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
    $ConfigurationPath = Join-Path $projectRoot '.ai-workflow.json'
}

function New-Check([string]$Name, [string]$Command, [string[]]$Arguments) {
    [pscustomobject]@{ name=$Name; command=$Command; args=@($Arguments) }
}

function Get-ConfiguredChecks([string]$Path) {
    $configuration = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ($configuration.version -ne 1) { throw "Unsupported configuration version: $($configuration.version)" }
    $names = @{}
    foreach ($check in @($configuration.checks)) {
        if ([string]::IsNullOrWhiteSpace($check.name) -or [string]::IsNullOrWhiteSpace($check.command)) {
            throw 'Every check requires non-empty name and command values.'
        }
        if ($names.ContainsKey($check.name)) { throw "Duplicate check name: $($check.name)" }
        $names[$check.name] = $true
        New-Check $check.name $check.command @($check.args)
    }
}

function Get-AutoDetectedChecks([string]$Root) {
    $checks = @()
    $packagePath = Join-Path $Root 'package.json'
    if (Test-Path -LiteralPath $packagePath) {
        $package = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
        foreach ($name in @('lint','typecheck','test','build')) {
            if ($package.scripts.PSObject.Properties.Name -contains $name) {
                $checks += New-Check $name 'npm' @('run', $name)
            }
        }
    }
    if (Get-ChildItem -LiteralPath $Root -Filter '*.sln' -File -ErrorAction SilentlyContinue) {
        $checks += New-Check 'dotnet-test' 'dotnet' @('test', '--nologo')
    }
    return $checks
}

function Get-ChangedFiles([string]$Root) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root '.git'))) { return @() }
    $lines = @(& git -C $Root status --short 2>$null)
    return @($lines | ForEach-Object {
        if ($_.Length -gt 3) { $_.Substring(3).Trim() }
    } | Where-Object { $_ })
}

$configured = Test-Path -LiteralPath $ConfigurationPath
$checks = if ($configured) { @(Get-ConfiguredChecks $ConfigurationPath) } else { @(Get-AutoDetectedChecks $projectRoot) }
if ($checks.Count -eq 0) { throw 'No checks found. Add .ai-workflow.json or supported project scripts.' }

$results = @()
foreach ($check in $checks) {
    $started = Get-Date
    if ($DryRun) {
        $results += [pscustomobject]@{ name=$check.name; command=$check.command; args=@($check.args); status='skipped'; exitCode=$null; durationMs=0; log='Dry run: command not executed.' }
        continue
    }

    $resolved = Get-Command $check.command -ErrorAction SilentlyContinue
    if (-not $resolved) {
        $results += [pscustomobject]@{ name=$check.name; command=$check.command; args=@($check.args); status='failed'; exitCode=127; durationMs=0; log="Executable not found: $($check.command)" }
        continue
    }

    $output = @(& $check.command @($check.args) 2>&1 | ForEach-Object { $_.ToString() })
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    $duration = [int]((Get-Date) - $started).TotalMilliseconds
    $results += [pscustomobject]@{
        name=$check.name; command=$check.command; args=@($check.args)
        status=if ($exitCode -eq 0) { 'passed' } else { 'failed' }
        exitCode=$exitCode; durationMs=$duration; log=($output -join [Environment]::NewLine)
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
    schemaVersion=1; generatedAt=(Get-Date).ToUniversalTime().ToString('o')
    project=[ordered]@{ name=(Split-Path -Leaf $projectRoot); path=$projectRoot }
    source=if ($configured) { 'configuration' } else { 'auto-detected' }
    dryRun=[bool]$DryRun; changedFiles=@(Get-ChangedFiles $projectRoot)
    checks=$results; summary=$summary; outcome=$outcome
}

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null
$jsonPath = Join-Path $ReportDirectory 'quality-report.json'
$markdownPath = Join-Path $ReportDirectory 'quality-report.md'
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding utf8

$markdown = @("# Change Quality Report", "", "- Outcome: **$outcome**", "- Source: $($report.source)", "- Generated: $($report.generatedAt)", "", "| Check | Status | Exit | Duration (ms) |", "| --- | --- | ---: | ---: |")
foreach ($result in $results) { $markdown += "| $($result.name) | $($result.status) | $($result.exitCode) | $($result.durationMs) |" }
$markdown += @('', "Changed files: $($report.changedFiles.Count)", '', '> Command logs are stored in `quality-report.json` and must be treated as untrusted text.')
$markdown | Set-Content -LiteralPath $markdownPath -Encoding utf8

Write-Output "Report: $markdownPath"
if ($outcome -eq 'failed') { exit 1 }
exit 0
