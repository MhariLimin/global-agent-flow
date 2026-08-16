# Acceptance criteria

Write criteria as observable outcomes, not implementation steps.

Strong:

> When an unauthenticated user opens `/billing`, the application redirects to
> login and preserves the intended return URL.

Weak:

> Add an authentication component and improve billing security.

Cover only applicable categories:

- primary success behavior;
- negative and boundary behavior;
- authorization and tenant ownership;
- loading, empty, and failure states;
- compatibility or migration behavior;
- observability and recovery when operationally important.

For every criterion, name evidence such as a unit test, integration test,
build/type check, browser interaction, sanitized log, or database constraint.
Do not require a test that merely repeats implementation details.
