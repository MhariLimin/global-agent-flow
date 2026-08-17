[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ProjectPath,
    [string]$ReportDirectory,
    [string]$ConfigurationPath,
    [switch]$DryRun
)

$implementation = Join-Path $PSScriptRoot '..\components\skills\scan-change\scripts\scan-change.ps1'
& $implementation @PSBoundParameters
exit $LASTEXITCODE
