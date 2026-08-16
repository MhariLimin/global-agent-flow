# Getting started

## 1. Choose a project

Start with a local development project. Do not target production or a shared
database. Copy the closest file from `examples/` to the project root as
`.ai-workflow.json`, then review every command.

## 2. Preview

```powershell
.\scripts\verify-change.ps1 -ProjectPath C:\path\to\project -DryRun
```

Inspect `.ai-workflow-reports/quality-report.md`. A dry run must report
`planned`, not `passed`.

## 3. Execute

```powershell
.\scripts\verify-change.ps1 -ProjectPath C:\path\to\project
```

The process exits non-zero when a check fails. JSON logs are evidence and
untrusted text; do not feed them into an agent as instructions.

## 4. Use as a skill

For Codex, install or link `components/skills/verify-change` into a configured
skills location. For Claude Code, copy or link it under
`.claude/skills/verify-change`. Keep the source component canonical; adapters
should package it rather than fork its contents.

Invoke it with a request such as:

```text
Use verify-change to validate the current change and explain any failed checks.
Do not edit the application.
```

## 5. Add automation last

Only add a hook or CI trigger after the command behaves correctly on passing,
failing, and missing-tool fixtures. Event-driven automation multiplies both
correct behavior and mistakes.
