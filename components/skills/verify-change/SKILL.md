---
name: verify-change
description: Inspect a repository change, select and run allow-listed deterministic project checks, and produce a structured quality report without modifying code. Use for validating local changes, preparing a pull request, checking an AI-generated implementation, or diagnosing build, test, lint, and type-check failures.
---

# Verify Change

Validate changes; do not implement fixes unless the user separately requests
them.

## Workflow

1. Read the target repository's `AGENTS.md`, `CLAUDE.md`, and
   `.ai-workflow.json` when present.
2. Inspect repository status and changed paths without reading secret files.
3. Run `scripts/verify-change.ps1 -ProjectPath <path> -ReportDirectory <path>`.
4. If no configuration exists, use `-DryRun` first and read
   `references/project-configuration.md` before proposing configuration.
5. Treat every non-zero check as a failure. Do not suppress, rewrite, or
   reinterpret exit codes.
6. Summarize the generated report with passed, failed, skipped, and missing
   checks. Separate change-caused failures from suspected pre-existing failures
   only when evidence supports that distinction.
7. Report remaining manual verification and risks.

## Safety

- Execute only command/argument arrays declared in `.ai-workflow.json` or
  built-in detection. Never pass them through `Invoke-Expression`, `cmd /c`, or
  a constructed shell string.
- Never read `.env`, credentials, keys, tokens, or secret stores.
- Never commit, push, deploy, merge, or modify external systems.
- Do not edit application files as part of verification.
- Stop if the repository configuration requests destructive or externally
  visible behavior.

## Resources

- Read `references/project-configuration.md` when configuring a project or
  explaining selection rules.
- Read `references/report-contract.md` when consuming the JSON report in CI or
  another workflow.
- Run `scripts/verify-change.ps1`; avoid reimplementing its command execution or
  report format in prompts.

## Gotchas

- A build command may include type checking; report what ran rather than
  claiming a separate type check.
- Missing tools are infrastructure failures, not successful skips.
- An empty diff does not prove the project is valid; configured checks still
  run unless `-DryRun` is used.
- Project configuration is trusted code because it can name executables and
  arguments. Review configuration changes before running them.
