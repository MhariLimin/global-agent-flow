[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ProjectPath,
    [string]$ReportDirectory,
    [string]$ConfigurationPath,
    [switch]$DryRun
)

$runner = Join-Path $PSScriptRoot '..\components\skills\verify-change\scripts\verify-change.ps1'
$arguments = @{ ProjectPath=$ProjectPath; DryRun=$DryRun }
if ($ReportDirectory) { $arguments.ReportDirectory = $ReportDirectory }
if ($ConfigurationPath) { $arguments.ConfigurationPath = $ConfigurationPath }
& $runner @arguments
exit $LASTEXITCODE
