---
name: scan-change
description: Run project-configured deterministic secret, dependency, static-analysis, or infrastructure security scanners and produce a normalized redacted pass/fail report. Use after implementation, before security review or human approval, when a user asks to scan a change, check dependencies or secrets, or collect security-tool evidence without exposing scanner output or secret values.
---

# Scan Change

Run deterministic security tools selected by the consuming project. Do not
install scanners, choose new vendors, or treat AI reasoning as scanner evidence.

## Workflow

1. Read project instructions and `.ai-workflow.json`.
2. Confirm every `securityChecks` command is project-approved, non-interactive,
   and side-effect-free. Treat configuration changes as executable code.
3. Preview with `scripts/scan-change.ps1 -ProjectPath <path> -DryRun` when the
   configuration is new or changed.
4. Run the script without `-DryRun` after approval.
5. Use only the normalized JSON/Markdown report for orchestration. Scanner
   arguments, stdout, and stderr are intentionally omitted from reports because
   they may contain credentials, matches, or sensitive source excerpts.
6. When a check fails, direct the human to run that scanner through its approved
   secure interface to inspect and remediate details.

## Guardrails

- Never read, reproduce, summarize, log, or transmit a detected secret value.
- Never weaken scanner rules, exclusions, baselines, or exit codes merely to
  obtain a passing result.
- Never execute a configured command through shell-string evaluation.
- Never install or upgrade a scanner automatically.
- Never upload source code or findings to an external service unless the user
  explicitly authorized that scanner and data flow.
- A missing executable is a failed check, not a skip.
- A passing scan is evidence within its configured scope, not proof of safety.

## Resources

- Run `scripts/scan-change.ps1` for deterministic execution and redacted reports.
- Read `references/project-configuration.md` when configuring a project.
- Read `references/report-contract.md` when consuming scan results.
