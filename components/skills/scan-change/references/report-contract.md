# Security report contract

`security-report.json` contains only normalized execution metadata:

- schema version and generation time;
- project name and local path;
- dry-run state and output policy;
- scanner name, kind, executable, status, exit code, and duration;
- pass/fail/skip totals and overall outcome.

Scanner arguments, stdout, and stderr are neither loaded into reports nor
stored. This prevents the orchestrator from copying credentials passed through
arguments, matched secrets, or sensitive source excerpts into reports or AI
context. The tradeoff is deliberate: a human must use the scanner's separately
approved secure interface for diagnostic details.

Exit code `127` means the configured executable is missing. Any failed or
missing check makes the overall scan fail. Dry runs produce `planned` with all
checks marked `skipped`.
