[CmdletBinding(DefaultParameterSetName='Path')]
param(
    [Parameter(Mandatory, ParameterSetName='Path')] [string]$Path,
    [Parameter(Mandatory, ParameterSetName='Event')] [string]$EventJson,
    [Parameter(Mandatory, ParameterSetName='EventFile')] [string]$EventFile,
    [ValidateSet('audit','enforce')] [string]$Mode = 'audit',
    [string]$PolicyPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'policy.json'
}

function Get-EventPath([string]$Json) {
    $event = $Json | ConvertFrom-Json
    foreach ($candidate in @(
        $event.tool_input.file_path,
        $event.tool_input.notebook_path,
        $event.file_path,
        $event.path
    )) {
        if (-not [string]::IsNullOrWhiteSpace([string]$candidate)) {
            return [string]$candidate
        }
    }
    throw 'The event does not contain a supported target path.'
}

function Test-Wildcard([string]$Value, [string]$Pattern) {
    return $Value -like $Pattern
}

$targetPath = if ($PSCmdlet.ParameterSetName -eq 'Event') {
    Get-EventPath $EventJson
} elseif ($PSCmdlet.ParameterSetName -eq 'EventFile') {
    Get-EventPath (Get-Content -LiteralPath $EventFile -Raw)
} else {
    $Path
}
$policy = Get-Content -LiteralPath $PolicyPath -Raw | ConvertFrom-Json
if ($policy.version -ne 1) { throw "Unsupported policy version: $($policy.version)" }

$leaf = Split-Path -Leaf ($targetPath -replace '/', '\')
$leafLower = $leaf.ToLowerInvariant()
$allowed = @($policy.allowedNames | Where-Object { $leafLower -eq $_.ToLowerInvariant() }).Count -gt 0
$matchedPattern = $null
if (-not $allowed) {
    foreach ($pattern in @($policy.protectedPatterns)) {
        if (Test-Wildcard $leafLower $pattern.ToLowerInvariant()) {
            $matchedPattern = $pattern
            break
        }
    }
}

$protected = $null -ne $matchedPattern
$decision = if (-not $protected) { 'allow' } elseif ($Mode -eq 'audit') { 'would-deny' } else { 'deny' }
$reason = if ($allowed) {
    'Allowed template filename.'
} elseif ($protected) {
    "Filename matches protected pattern '$matchedPattern'."
} else {
    'Filename does not match the protected-file policy.'
}

$result = [ordered]@{
    policyVersion = $policy.version
    mode = $Mode
    decision = $decision
    path = $targetPath
    reason = $reason
}
$result | ConvertTo-Json -Compress

if ($decision -eq 'deny') { exit 2 }
exit 0
