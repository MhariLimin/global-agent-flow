# Project configuration

Place `.ai-workflow.json` in a consuming repository root.

```json
{
  "$schema": "https://example.invalid/ai-workflow.schema.json",
  "version": 1,
  "project": "example",
  "checks": [
    {
      "name": "typecheck",
      "command": "npm",
      "args": ["run", "typecheck"],
      "paths": ["src/**", "*.json"]
    }
  ]
}
```

`name`, `command`, and `args` are required. `paths` is reserved for future
scoped selection; version 1 runs all configured checks so correctness does not
depend on incomplete path matching.

Keep commands non-interactive and side-effect-free. Checks may compile into
ignored build directories, but must not deploy, publish, change databases, or
write external state. Treat configuration changes like executable code.

If configuration is absent, the runner detects:

- Node: scripts named `lint`, `typecheck`, `test`, and `build` in `package.json`.
- .NET: `dotnet test --nologo` when a solution exists.

Auto-detection is a bootstrap. Commit an explicit configuration when a project
needs ordering, additional arguments, or different checks.
