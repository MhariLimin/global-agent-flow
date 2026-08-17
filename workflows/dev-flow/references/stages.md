# Dev Flow stages

| Stage | Input | Required output | Blocking condition |
| --- | --- | --- | --- |
| Prepare | Request and repository | Change brief | Material unknown |
| Gate A | Change brief | Approved scope or requested revision | Human decision required |
| Implement | Approved brief | Scoped diff | Conflict, missing authority, or changed premise |
| Verify | Diff and project config | Deterministic report | Any required failed/missing check |
| Review | Brief, diff, verification | Prioritized findings | Critical/high or accepted project-defined blocker |
| Security review | Brief, diff, verification | Security findings and residual risk | Critical/high or accepted security blocker |
| Remediate | Approved findings | Corrected diff | Loop limit or new material decision |
| Gate B | All artifacts | Human accept/revise/reject decision | Human decision required |

## Small changes

For a low-risk, well-defined change, Gate A may be implicit in the user's direct
implementation request when no material choice exists. Still preserve the
brief's outcome, constraints, and acceptance criteria. Gate B never authorizes
external actions unless those actions were explicitly requested.

## Bug route

Do not implement a guessed fix. The diagnostic artifact must identify a
demonstrated root cause or clearly label the leading hypothesis and approved
experiment.
