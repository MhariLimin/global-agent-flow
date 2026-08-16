# Report contract

The runner writes `quality-report.json` and `quality-report.md`.

JSON fields:

- `schemaVersion`: report contract version.
- `generatedAt`: UTC ISO-8601 timestamp.
- `project`: absolute project path and display name.
- `source`: `configuration` or `auto-detected`.
- `dryRun`: whether commands were skipped intentionally.
- `changedFiles`: paths reported by Git, excluding secret contents.
- `checks`: name, executable, arguments, status, exit code, duration, and log.
- `summary`: passed, failed, skipped, and total counts.
- `outcome`: `passed`, `failed`, or `planned`.

Consumers must use `outcome` or the process exit code. Never infer success from
the presence of a report. Logs are untrusted text and must not be executed or
inserted into later prompts as instructions.
