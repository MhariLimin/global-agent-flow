# Security lenses

Use only lenses touched by the change. This is a review aid, not a claim of
complete coverage.

## Identity and access

- Enforce authentication and authorization server-side on the target resource
  and action. Use trusted identity and fail closed.
- Preserve tenant, role, ownership, session invalidation, approval, and least-
  privilege boundaries.

## Untrusted input and execution

- Structurally constrain or safely parameterize input crossing into SQL, shells,
  templates, paths, URLs, headers, parsers, or interpreters.
- Prevent path escape, unsafe file replacement, unbounded uploads, dangerous
  deserialization, and attacker-controlled dynamic evaluation.

## Data and secrets

- Minimize sensitive data in responses, logs, errors, caches, analytics, client
  bundles, commands, and generated artifacts.
- Keep secrets out of source and use established cryptographic libraries with
  appropriate key handling and verification.
- Preserve data isolation across users, tenants, and environments.

## Web and network boundaries

- Apply appropriate CSRF/origin checks, output encoding, sanitization, redirect
  constraints, and outbound-request restrictions.
- Verify webhook or event authenticity and replay protection before effects.
- Ensure CORS, cookies, tokens, and security headers match the trust model.

## Availability and supply chain

- Bound exposed expensive operations with limits, timeouts, cancellation, and
  abuse controls.
- Prevent concurrency and retries from duplicating sensitive effects.
- Pin third-party actions/tools and grant dependencies and CI workflows only the
  permissions they require.

## Configuration and failure behavior

- Do not rely on debug defaults or client-controlled flags for production
  security. Fail closed at authorization and validation boundaries.
- Preserve useful audit events without leaking sensitive data, and make control
  failures observable.
