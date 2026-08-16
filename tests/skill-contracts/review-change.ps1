$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillRoot = Join-Path $repository 'components\skills\review-change'
$content = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw

if ($content -notmatch '(?s)^---\s+name: review-change\s+description: .+?\s+---') {
    throw 'review-change frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'review-change contains unresolved TODO markers.' }

foreach ($required in @(
    'references\finding-quality.md',
    'references\severity.md',
    'references\review-lenses.md',
    'assets\review-report-template.md',
    'agents\openai.yaml'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $required))) {
        throw "review-change is missing $required."
    }
}

foreach ($requirement in @(
    'exact file and narrow location',
    'realistic input, state, or execution path',
    'Do not report style preferences',
    'Do not edit, commit, push'
)) {
    if ($content -notmatch [regex]::Escape($requirement)) {
        throw "review-change is missing requirement: $requirement"
    }
}

Write-Output 'PASS: review-change contract'
