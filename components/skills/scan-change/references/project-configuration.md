# Security scan configuration

Add `securityChecks` to the consuming project's `.ai-workflow.json`:

```json
{
  "version": 1,
  "project": "example",
  "checks": [
    { "name": "test", "command": "npm", "args": ["test"] }
  ],
  "securityChecks": [
    {
      "name": "dependency-audit",
      "kind": "dependency",
      "command": "npm",
      "args": ["audit", "--audit-level=high"]
    }
  ]
}
```

Supported `kind` values are `secret`, `dependency`, `sast`, `infrastructure`,
and `other`. The project chooses and installs its scanners. Commands must be
non-interactive, side-effect-free, and configured to return nonzero when the
project's security threshold is violated.

Do not place credentials in arguments. Review scanner network behavior and data
handling before authorizing cloud-backed tools. Prefer lockfile-aware native
dependency audits and scanners already approved for the project.
