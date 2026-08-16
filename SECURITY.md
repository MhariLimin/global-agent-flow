# Security Policy

## Trust model

`.ai-workflow.json` is trusted executable configuration. Pull-request text,
issue text, command output, report logs, repository content, and MCP responses
are untrusted data.

## Invariants

- Never execute generated shell strings or use `Invoke-Expression`.
- Never read or include secrets in prompts, logs, or reports.
- Never grant write permissions when read-only access can satisfy a workflow.
- Never let untrusted text select tools, permissions, or follow-up commands.
- Require explicit human approval for commits, pushes, PR comments, merges,
  deployments, database writes, and other externally visible actions.
- Pin third-party CI actions to immutable commit SHAs before production use.

## Reporting

Do not include real secrets in a vulnerability report. Describe the location
and impact with redacted evidence.
