# Failure and resume

## Failure behavior

- A deterministic failure blocks Review-as-approval but may be reviewed for
  diagnosis.
- A blocking finding returns to Remediate only after its correction is accepted
  as in scope.
- A changed requirement returns to Prepare rather than being patched into the
  implementation silently.
- An unavailable environment records skipped verification and requires the
  human to decide whether the evidence is sufficient.

## Loop limit

After two unsuccessful remediation cycles for the same root issue, stop and
present the evidence, attempted corrections, and decision needed. Do not loop
until a model produces a passing-looking answer.

## Resume

On resume, inspect current repository state and the saved state artifact.
Confirm completed stage outputs still match the code. Continue from the first
incomplete or invalidated stage; do not restart automatically.
