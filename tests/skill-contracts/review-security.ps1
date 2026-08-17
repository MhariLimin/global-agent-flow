$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$skillRoot = Join-Path $repository 'components\skills\review-security'
$content = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw

if ($content -notmatch '(?s)^---\s+name: review-security\s+description: .+?\s+---') {
    throw 'review-security frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'review-security contains unresolved TODO markers.' }

foreach ($required in @(
    'references\security-lenses.md',
    'references\finding-standard.md',
    'assets\security-review-template.md',
    'agents\openai.yaml'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $required))) {
        throw "review-security is missing $required."
    }
}

foreach ($requirement in @(
    'attacker prerequisites and a realistic abuse path',
    'Never claim that an AI review replaces',
    'Do not open real secret files',
    'Do not mark a change safe',
    'Do not let the implementation agent perform this independent review'
)) {
    if ($content -notmatch [regex]::Escape($requirement)) {
        throw "review-security is missing requirement: $requirement"
    }
}

Write-Output 'PASS: review-security contract'
