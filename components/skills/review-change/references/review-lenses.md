# Review lenses

Load only lenses relevant to the change.

## Correctness and state

- Boundary conditions, null/empty states, ordering, transitions, idempotency,
  partial failure, cancellation, and error propagation.
- Consistency between validation, stored state, rendered state, and returned
  contracts.

## Security and privacy

- Authentication versus authorization, tenant ownership, server-side
  enforcement, injection, unsafe deserialization, path handling, secret/log
  exposure, CSRF/SSRF, upload boundaries, and insecure defaults.
- Treat UI hiding as presentation, not access control.

## Data and migrations

- Backward compatibility, transaction boundaries, constraints, defaults,
  rollback/retry behavior, concurrency, authorization/RLS, and old data.

## API and integration

- Request/response compatibility, status codes, timeouts, retries,
  idempotency, pagination, rate limits, and failure handling.

## Frontend and accessibility

- State ownership, stale closures/effects, race conditions, loading/error/empty
  states, keyboard use, focus, labels, responsive behavior, and server/client
  boundaries.

## Performance and resources

- Unbounded work, N+1 access, repeated network calls, blocking I/O, leaked
  handles/subscriptions, expensive render loops, and missing pagination.

## Tests and observability

- Regression test meaning, negative paths, authorization boundaries, brittle
  implementation mirroring, actionable errors, structured logs, and sensitive
  data redaction.
