$ErrorActionPreference = 'Stop'
$eventJson = [Console]::In.ReadToEnd()
$guard = Join-Path $PSScriptRoot 'guard-protected-file.ps1'

& $guard -EventJson $eventJson -Mode enforce 1>&2
exit $LASTEXITCODE
