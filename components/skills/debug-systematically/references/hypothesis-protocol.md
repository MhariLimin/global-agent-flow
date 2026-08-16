# Hypothesis protocol

Use this protocol when the cause is not already demonstrated.

## Build the evidence table

| Hypothesis | Why plausible | Discriminating experiment | Supporting result | Falsifying result |
| --- | --- | --- | --- | --- |

Prefer two to four hypotheses. Rank them by evidence and diagnostic value, not
by ease of editing.

## Choose experiments

A useful experiment changes one variable, has an observable result, and
distinguishes between hypotheses. Prefer read-only inspection and narrow tests
before code edits.

Weak experiment:

> Rewrite the component and see whether it works.

Strong experiment:

> Call the API directly with the same identifier. If it returns the expected
> entity, investigate frontend state; if it returns 404, trace routing or data.

## Intermittent failures

Record timing, frequency, environment, ordering, concurrency, and seed/input.
Increase observability before increasing retries. A retry can reduce symptoms
while preserving a race, deadlock, timeout, or unavailable dependency.

## Root-cause claim

Claim a root cause only when evidence connects:

```text
trigger -> faulty state or decision -> observed failure
```

If only correlation is available, label the conclusion as a leading hypothesis
and name the next experiment.
