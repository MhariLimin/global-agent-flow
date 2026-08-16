[CmdletBinding(DefaultParameterSetName='Path')]
param(
    [Parameter(Mandatory, ParameterSetName='Path')] [string]$Path,
    [Parameter(Mandatory, ParameterSetName='Event')] [string]$EventJson,
    [string]$ProjectPath,
    [string]$ConfigurationPath
)

$ErrorActionPreference = 'Stop'

function Get-EventData([string]$Json) {
    $event = $Json | ConvertFrom-Json
    $target = @($event.tool_input.file_path, $event.tool_input.notebook_path, $event.file_path, $event.path) |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
        Select-Object -First 1
    if (-not $target) { throw 'The event does not contain a supported target path.' }
    [pscustomobject]@{ path=[string]$target; cwd=[string]$event.cwd }
}

function New-Result([string]$Check, [string]$Status, [string]$Message, [Nullable[int]]$ExitCode) {
    [ordered]@{ check=$Check; status=$Status; path=$targetPath; message=$Message; exitCode=$ExitCode }
}

if ($PSCmdlet.ParameterSetName -eq 'Event') {
    $eventData = Get-EventData $EventJson
    $targetPath = $eventData.path
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) { $ProjectPath = $eventData.cwd }
} else {
    $targetPath = $Path
}
if ([string]::IsNullOrWhiteSpace($ProjectPath)) { $ProjectPath = (Get-Location).Path }
$projectRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
$absoluteTarget = if ([IO.Path]::IsPathRooted($targetPath)) { $targetPath } else { Join-Path $projectRoot $targetPath }
if (-not (Test-Path -LiteralPath $absoluteTarget -PathType Leaf)) {
    (New-Result 'file-exists' 'failed' 'Edited file was not found.' 1) | ConvertTo-Json -Compress
    exit 1
}

$extension = [IO.Path]::GetExtension($absoluteTarget).ToLowerInvariant()
$result = $null
if ($extension -eq '.json') {
    try {
        Get-Content -LiteralPath $absoluteTarget -Raw | ConvertFrom-Json | Out-Null
        $result = New-Result 'json-parse' 'passed' 'JSON syntax is valid.' 0
    } catch {
        $result = New-Result 'json-parse' 'failed' $_.Exception.Message 1
    }
} elseif ($extension -in @('.ps1','.psm1','.psd1')) {
    $tokens = $null
    $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($absoluteTarget, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -eq 0) {
        $result = New-Result 'powershell-parse' 'passed' 'PowerShell syntax is valid.' 0
    } else {
        $message = @($errors | ForEach-Object { "line $($_.Extent.StartLineNumber): $($_.Message)" }) -join '; '
        $result = New-Result 'powershell-parse' 'failed' $message 1
    }
}

if (-not $result) {
    if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) { $ConfigurationPath = Join-Path $projectRoot '.ai-workflow.json' }
    if (Test-Path -LiteralPath $ConfigurationPath) {
        $configuration = Get-Content -LiteralPath $ConfigurationPath -Raw | ConvertFrom-Json
        $match = @($configuration.fastChecks | Where-Object { @($_.extensions | ForEach-Object { $_.ToLowerInvariant() }) -contains $extension }) | Select-Object -First 1
        if ($match) {
            $resolved = Get-Command $match.command -ErrorAction SilentlyContinue
            if (-not $resolved) {
                $result = New-Result $match.name 'failed' "Executable not found: $($match.command)" 127
            } else {
                $relativePath = [IO.Path]::GetRelativePath($projectRoot, $absoluteTarget)
                $arguments = @($match.args | ForEach-Object { ([string]$_).Replace('{path}', $relativePath) })
                Push-Location $projectRoot
                try {
                    $output = @(& $match.command @arguments 2>&1 | ForEach-Object { $_.ToString() })
                    $code = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
                } finally { Pop-Location }
                $result = New-Result $match.name $(if ($code -eq 0) {'passed'} else {'failed'}) ($output -join [Environment]::NewLine) $code
            }
        }
    }
}

if (-not $result) { $result = New-Result 'none' 'skipped' "No fast check is configured for $extension files." $null }
$result | ConvertTo-Json -Compress
if ($result.status -eq 'failed') { exit 1 }
exit 0
