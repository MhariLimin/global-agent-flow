---
name: review-change
description: Perform a read-only review of a local diff, branch, commit, or pull request and report only concrete, actionable defects in correctness, security, reliability, testing, performance, and project architecture. Use after implementation, before commit or merge, when reviewing AI-generated code, or when a user asks for code review, PR review, risk assessment, or regression analysis.
---

# Review Change

Review like an independent maintainer. Do not modify code.

## Workflow

1. Read project instructions and determine the intended behavior, comparison
   base, and review scope.
2. Inspect repository status and the complete relevant diff. Include new,
   deleted, renamed, generated, configuration, migration, and test files.
3. Read enough surrounding code to understand callers, state ownership, trust
   boundaries, and established patterns. Do not judge isolated lines without
   context.
4. Consult deterministic results from `verify-change` when available. A passing
   build or test suite is evidence, not proof of correctness.
5. Review using the applicable lenses in `references/review-lenses.md`.
6. Validate each suspected issue against `references/finding-quality.md`.
7. Rank valid findings using `references/severity.md`.
8. Report findings in priority order using `assets/review-report-template.md`.
   If there are no findings, say so and name any meaningful unverified risks.

## Finding requirements

Include a finding only when all are present:

- an exact file and narrow location;
- the violated behavior or invariant;
- a realistic input, state, or execution path that triggers the defect;
- the resulting impact;
- a direction for correction;
- a confidence level.

## Guardrails

- Do not report style preferences, optional refactors, or speculative concerns
  as defects.
- Do not infer a bug from unfamiliar code before checking callers and project
  conventions.
- Do not report pre-existing problems unless the change makes them newly
  reachable or materially worse; list them separately when relevant.
- Do not duplicate one root cause across multiple findings.
- Do not expose secrets or include sensitive values in evidence.
- Do not approve a change merely because deterministic checks pass.
- Do not edit, commit, push, comment on a PR, or change external state.

## Resources

- Read `references/review-lenses.md` selectively for the affected boundaries.
- Read `references/finding-quality.md` before finalizing findings.
- Read `references/severity.md` when ranking impact.
- Use `assets/review-report-template.md` for durable reports and CI artifacts.
