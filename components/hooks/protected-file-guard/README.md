# Protected File Guard

Deterministically block agent writes to common secret and private-key files.
The guard compares paths only; it never opens the target file.

## Modes

- `audit`: report `would-deny` but exit successfully.
- `enforce`: deny protected paths with exit code `2`.

Start new integrations in audit mode, inspect results, then enable enforcement.

## Direct usage

```powershell
.\guard-protected-file.ps1 -Path '.env.local' -Mode audit
.\guard-protected-file.ps1 -Path '.env.local' -Mode enforce
.\guard-protected-file.ps1 -Path '.env.example' -Mode enforce
```

The script emits one JSON result with `decision`, `reason`, `path`, and
`policyVersion`. Treat paths as untrusted display text and do not execute them.

## Design limits

This is a narrow file-name guard, not a malware scanner, secret scanner, or
general command firewall. It cannot detect a secret stored under an innocent
filename. Native provider sandbox and approval controls remain necessary.
