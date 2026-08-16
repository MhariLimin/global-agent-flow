# Fast Feedback Hook

Run narrow, deterministic diagnostics immediately after an agent edits a file.
The hook reports problems but never rewrites the file.

Built-in checks:

- JSON parsing for `.json` files.
- PowerShell parser diagnostics for `.ps1`, `.psm1`, and `.psd1` files without
  executing them.

Projects can declare additional `fastChecks` in `.ai-workflow.json`. Commands
and arguments are passed separately; `{path}` is replaced only inside an
argument value.

Unsupported files return `skipped`. Use `verify-change` for broad project
validation.
