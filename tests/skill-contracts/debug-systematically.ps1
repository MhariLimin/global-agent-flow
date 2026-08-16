$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillRoot = Join-Path $repository 'components\skills\debug-systematically'
$skillPath = Join-Path $skillRoot 'SKILL.md'
$content = Get-Content -LiteralPath $skillPath -Raw

if ($content -notmatch '(?s)^---\s+name: debug-systematically\s+description: .+?\s+---') {
    throw 'debug-systematically frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'debug-systematically contains unresolved TODO markers.' }

foreach ($required in @(
    'references\hypothesis-protocol.md',
    'references\stack-signals.md',
    'assets\debug-report-template.md',
    'agents\openai.yaml'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $required))) {
        throw "debug-systematically is missing $required."
    }
}

foreach ($guardrail in @(
    'one discriminating experiment at a time',
    'Do not weaken, delete, or skip a failing test',
    'Keep diagnosis separate from implementation'
)) {
    if ($content -notmatch [regex]::Escape($guardrail)) {
        throw "debug-systematically is missing guardrail: $guardrail"
    }
}

Write-Output 'PASS: debug-systematically contract'
