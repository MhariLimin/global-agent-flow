$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$workflowRoot = Join-Path $repository 'workflows\dev-flow'
$content = Get-Content -LiteralPath (Join-Path $workflowRoot 'SKILL.md') -Raw

if ($content -notmatch '(?s)^---\s+name: dev-flow\s+description: .+?\s+---') {
    throw 'dev-flow frontmatter is invalid.'
}
if ($content -match 'TODO') { throw 'dev-flow contains unresolved TODO markers.' }

foreach ($required in @(
    'references\stages.md',
    'references\handoff-contracts.md',
    'references\failure-and-resume.md',
    'assets\dev-flow-state-template.md',
    'agents\openai.yaml'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $workflowRoot $required))) {
        throw "dev-flow is missing $required."
    }
}

foreach ($requirement in @(
    'Gate A',
    'Gate B',
    'Never auto-approve gates',
    'Never commit, push',
    'repeat Verify and Review'
)) {
    if ($content -notmatch [regex]::Escape($requirement)) {
        throw "dev-flow is missing requirement: $requirement"
    }
}
if ($content -notmatch 'failed\s+deterministic checks block\s+progression') {
    throw 'dev-flow is missing the deterministic failure gate.'
}

Write-Output 'PASS: dev-flow contract'
