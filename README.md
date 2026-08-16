# Global Agent Flow

A provider-neutral foundation for building, testing, and evaluating reusable
skills, hooks, scripts, and AI-assisted development workflows.

This repository is intentionally provider-neutral at its core. Components keep
reasoning in Agent Skills, repeatable behavior in deterministic scripts, and
provider-specific packaging in adapters.

## Current release: vertical slice 0.1

The first component is `verify-change`. It:

- reads a small project-owned configuration or detects common Node/.NET checks;
- invokes commands without shell-string evaluation;
- preserves failures and command logs;
- creates stable JSON and Markdown reports;
- performs no commits, pushes, deployments, or external writes.

The first hook component is `protected-file-guard`. It compares intended write
paths against a tested filename policy without opening the files. Start it in
audit mode before enabling enforcement through a provider adapter.

`fast-feedback` runs narrow post-edit diagnostics. It validates JSON and
PowerShell syntax out of the box and supports project-configured, path-scoped
commands without automatically rewriting files.

`debug-systematically` is the first diagnosis skill. It requires reproduction,
ranked hypotheses, discriminating experiments, demonstrated root cause, and
regression evidence before a bug is considered resolved.

`review-change` is a read-only independent review skill. It reports only
concrete, triggered defects with impact, evidence, correction direction, and
confidence; deterministic checks remain a separate evidence layer.

`prepare-change` is the context-engineering entry point. It turns a request into
an evidence-backed brief with selected context, known/assumed/unknown facts,
testable acceptance criteria, risks, and implementation handoff.

`workflows/dev-flow` coordinates feature and bug work through preparation,
implementation, deterministic verification, independent review, remediation,
and two explicit human decision gates.

Run it directly:

```powershell
.\scripts\verify-change.ps1 -ProjectPath C:\path\to\project -DryRun
.\scripts\verify-change.ps1 -ProjectPath C:\path\to\project
```

See `docs/getting-started.md` and `examples/` to integrate a project.

## Architecture

```text
project request
  -> skill (reasoning and selection)
  -> script (deterministic execution)
  -> report contract (evidence)
  -> future hooks/reviewers/CI gates
```

The consuming project owns its architecture, commands, and security rules. This
repository owns reusable execution and reporting behavior.

## Status

Experimental. Version 0.1 proves one reusable component before introducing
hooks, subagents, MCP, or autonomous CI behavior. See `ROADMAP.md`.

## Safety

Review `.ai-workflow.json` changes as executable code. This project does not
read secrets or authorize deployments. See `SECURITY.md`.

## License

MIT
