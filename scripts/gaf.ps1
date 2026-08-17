[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('install', 'sync', 'verify', 'scan', 'status')]
    [string]$Command = 'status',

    [Parameter(Position=1)]
    [string]$ProjectPath = (Get-Location).Path,

    [ValidateSet('all', 'codex', 'claude')]
    [string]$Provider = 'all',

    [string]$UserHome = [Environment]::GetFolderPath('UserProfile'),
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repository = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$manifestName = '.gaf-managed.json'
$components = @(
    @{ Name='verify-change'; Source='components\skills\verify-change' },
    @{ Name='debug-systematically'; Source='components\skills\debug-systematically' },
    @{ Name='review-change'; Source='components\skills\review-change' },
    @{ Name='review-security'; Source='components\skills\review-security' },
    @{ Name='prepare-change'; Source='components\skills\prepare-change' },
    @{ Name='scan-change'; Source='components\skills\scan-change' },
    @{ Name='dev-flow'; Source='workflows\dev-flow' }
)

function Get-ProviderTargets {
    $targets = @()
    if ($Provider -in @('all', 'codex')) {
        $targets += @{ Name='codex'; Root=(Join-Path $UserHome '.agents\skills') }
    }
    if ($Provider -in @('all', 'claude')) {
        $targets += @{ Name='claude'; Root=(Join-Path $UserHome '.claude\skills') }
    }
    return $targets
}

function Read-ManagedMarker([string]$Destination) {
    $markerPath = Join-Path $Destination $manifestName
    if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) { return $null }
    return Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
}

function Install-Component($Target, $Component, [bool]$IsSync) {
    $source = (Resolve-Path -LiteralPath (Join-Path $repository $Component.Source)).Path
    $destination = Join-Path $Target.Root $Component.Name

    if (Test-Path -LiteralPath $destination) {
        $marker = Read-ManagedMarker $destination
        if ($null -eq $marker -or $marker.component -ne $Component.Name) {
            throw "Refusing to overwrite unmanaged skill: $destination"
        }
        if (-not $IsSync) {
            Write-Output "Already installed: $($Target.Name)/$($Component.Name)"
            return
        }
        Remove-Item -LiteralPath $destination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path (Join-Path $source '*') -Destination $destination -Recurse -Force
    [ordered]@{
        schemaVersion=1
        component=$Component.Name
        provider=$Target.Name
        sourceRepository=$repository
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $destination $manifestName) -Encoding utf8
    Write-Output "$($(if ($IsSync) { 'Synced' } else { 'Installed' })): $($Target.Name)/$($Component.Name)"
}

function Install-All([bool]$IsSync) {
    foreach ($target in Get-ProviderTargets) {
        New-Item -ItemType Directory -Path $target.Root -Force | Out-Null
        foreach ($component in $components) {
            Install-Component $target $component $IsSync
        }
    }
}

function Show-Status {
    foreach ($target in Get-ProviderTargets) {
        foreach ($component in $components) {
            $destination = Join-Path $target.Root $component.Name
            $marker = if (Test-Path -LiteralPath $destination) { Read-ManagedMarker $destination } else { $null }
            $state = if ($null -ne $marker -and $marker.component -eq $component.Name) {
                'managed'
            } elseif (Test-Path -LiteralPath $destination) {
                'unmanaged'
            } else {
                'missing'
            }
            Write-Output "$($target.Name)/$($component.Name): $state"
        }
    }
}

switch ($Command) {
    'install' { Install-All $false }
    'sync' { Install-All $true }
    'status' { Show-Status }
    'verify' {
        $arguments = @{ ProjectPath=$ProjectPath }
        if ($DryRun) { $arguments.DryRun = $true }
        & (Join-Path $repository 'scripts\verify-change.ps1') @arguments
        exit $LASTEXITCODE
    }
    'scan' {
        $arguments = @{ ProjectPath=$ProjectPath }
        if ($DryRun) { $arguments.DryRun = $true }
        & (Join-Path $repository 'scripts\scan-change.ps1') @arguments
        exit $LASTEXITCODE
    }
}
