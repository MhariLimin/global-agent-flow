# Stack evidence signals

Load only the relevant section.

## Browser and frontend

- Reproduce with exact route, viewport, state, and interaction sequence.
- Inspect console errors, network status/payload, component state ownership,
  event order, and source maps.
- Separate rendering defects from API/data defects by exercising the boundary.

## HTTP and backend

- Capture method, route, status, correlation identifier, sanitized request, and
  sanitized response.
- Trace validation, authentication, authorization, domain logic, persistence,
  and serialization in order.
- Distinguish handler failure from dependency or configuration failure.

## Database and persistence

- Verify the target environment before any operation.
- Inspect generated query, parameters with sensitive values redacted,
  transaction boundary, migration state, constraints, and authorization/RLS.
- Never use production mutation as a diagnostic experiment.

## Build and toolchain

- Record exact command, working directory, runtime/SDK version, lockfile, first
  causal error, and environment differences.
- Treat later cascading errors as symptoms until the earliest failure is
  understood.
- Do not upgrade dependencies as a first diagnostic action.

## Concurrency and timing

- Capture ordering, shared state, cancellation, timeout, and retry behavior.
- Prefer deterministic clocks, barriers, seeds, or repeated focused tests.
- A longer delay is evidence only if the timing boundary itself is the tested
  hypothesis.
