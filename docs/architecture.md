# Architecture and decisions

## Boundaries

```text
project-owned knowledge/configuration
               |
               v
provider-neutral skill -> deterministic runner -> versioned reports
               ^                                  |
               |                                  v
       Claude/Codex adapters                 CI/eval consumers
```

- **Project instructions** define local truth and invariants.
- **Skills** select and interpret; their output is probabilistic.
- **Scripts** execute allow-listed checks and preserve evidence.
- **Adapters** handle discovery/packaging without duplicating core behavior.
- **Reports** are the stable boundary for future hooks, CI, and evals.

## Decisions

### PowerShell first

The initial users and projects run on Windows. PowerShell 7 is also available
on common CI runners. A future portable implementation must preserve the report
contract and security properties rather than merely port syntax.

### Configuration is trusted code

Executable names and arguments can cause side effects even without shell
evaluation. Configuration therefore requires code review. Later policy layers
may restrict executable names, but cannot infer whether an arbitrary test
command is safe.

### No AI call in version 0.1

The first layer proves deterministic validation without API keys, cost, model
variance, or network access. Agent-driven review will consume its reports in a
later version and will be evaluated separately.
