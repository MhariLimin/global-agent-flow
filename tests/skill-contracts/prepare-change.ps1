$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillRoot = Join-Path $repository 'components\skills\prepare-change'
$content = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw

if ($content -notmatch '(?s)^---\s+name: prepare-change\s+description: .+?\s+---') {
    throw 'prepare-change frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'prepare-change contains unresolved TODO markers.' }

foreach ($required in @(
    'references\context-selection.md',
    'references\acceptance-criteria.md',
    'assets\change-brief-template.md',
    'agents\openai.yaml'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $required))) {
        throw "prepare-change is missing $required."
    }
}

foreach ($requirement in @(
    'Known',
    'Assumed',
    'Unknown',
    'observable acceptance criteria',
    'Ask a question only when an unknown would materially change',
    'Do not edit application code'
)) {
    if ($content -notmatch [regex]::Escape($requirement)) {
        throw "prepare-change is missing requirement: $requirement"
    }
}

Write-Output 'PASS: prepare-change contract'
