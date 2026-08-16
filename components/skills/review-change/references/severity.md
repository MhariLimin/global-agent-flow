# Severity model

Rank by impact and likelihood, not by how easy the fix is.

- **Critical:** likely catastrophic compromise, irreversible data loss, or
  broad production outage; should block release immediately.
- **High:** security boundary bypass, cross-tenant exposure, substantial data
  corruption, or common-path failure; should block merge.
- **Medium:** real defect affecting a narrower path, recoverable reliability
  issue, or missing regression coverage for consequential behavior; normally
  fix before merge.
- **Low:** limited-impact defect with a realistic trigger; may be scheduled.

Do not use severity for style, maintainability preferences, or vague future
risks. Put those in an optional non-blocking note only when the user asks.
