---
name: debug-systematically
description: Diagnose reproducible software failures with an evidence-led workflow that separates symptoms from root causes, tests one hypothesis at a time, applies the smallest justified fix, and verifies regression evidence. Use for bugs, failing tests or builds, runtime errors, incorrect behavior, intermittent failures, performance regressions, and integration or configuration problems.
---

# Debug Systematically

Find the root cause before implementing a fix.

## Workflow

1. Read project instructions and preserve unrelated changes.
2. Restate the expected behavior, actual behavior, and available evidence.
3. Reproduce the failure with the smallest reliable command or interaction. If
   reproduction is impossible, state what evidence is missing instead of
   guessing.
4. Trace the failing path from observed symptom toward the responsible boundary.
5. List a small set of ranked hypotheses. For each, identify evidence that
   would support or falsify it.
6. Run one discriminating experiment at a time. Record the result before
   changing the next variable.
7. Name the root cause and connect it to the original symptom with evidence.
8. Implement the smallest coherent fix only when the user requested a fix.
9. Add or identify regression evidence that fails before the fix and passes
   after it. Use `verify-change` for configured deterministic checks when
   available.
10. Report using `assets/debug-report-template.md`.

## Guardrails

- Do not make multiple speculative fixes at once.
- Do not treat disappearance of the symptom as proof of root cause.
- Do not weaken, delete, or skip a failing test merely to obtain a pass.
- Do not add retries, sleeps, broad exception handling, cache clearing, or
  dependency upgrades without evidence that they address the cause.
- Do not expose secrets in commands, logs, reports, or screenshots.
- Keep diagnosis separate from implementation when the request asks only for
  analysis.

## Resources

- Read `references/hypothesis-protocol.md` when the cause is unclear, multiple
  explanations fit, or the failure is intermittent.
- Read `references/stack-signals.md` for browser/frontend, HTTP/backend,
  database, build/toolchain, and concurrency evidence sources.
- Copy `assets/debug-report-template.md` when a durable debugging artifact is
  useful; otherwise use the same headings in the final response.

## Stop conditions

Stop and report the blocker when reproduction requires unavailable credentials,
a production-only environment, destructive data changes, or external authority.
Do not manufacture certainty from incomplete evidence.
