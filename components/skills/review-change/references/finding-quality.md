# Finding quality

Use this gate before reporting an issue.

## Required chain

```text
changed behavior -> triggering condition -> incorrect result -> user/system impact
```

Reject a finding when any link is missing or depends on an unsupported
assumption.

## Location

Point to the smallest changed range that causes or enables the issue. The
location must overlap the change unless the changed code makes an existing
defect newly reachable.

## Evidence

Prefer a failing test, reproducible path, violated invariant, API contract,
authorization boundary, or direct control/data-flow trace. Do not quote secrets.

## Confidence

- **High:** directly demonstrated or unavoidable from the code path.
- **Medium:** strongly supported but depends on one documented assumption.
- **Low:** plausible but insufficiently supported; normally omit and place in
  unverified risks instead.

## False-positive checks

Before reporting, ask:

- Is the behavior intentional or documented?
- Is validation or protection applied by a caller, framework, database, or
  middleware?
- Can the triggering state actually occur?
- Is this introduced by the reviewed change?
- Is this only a preference with no incorrect outcome?
