# Security finding standard

## Evidence threshold

A reportable finding needs a traceable abuse path:

1. Attacker capability or controlled input.
2. Reachable changed code or newly affected boundary.
3. Missing or bypassed control.
4. Security-relevant effect.
5. Concrete impact.

If any link is unverified, investigate it or label the item as an unverified
surface rather than a finding.

## Severity

- **Critical:** practical compromise with catastrophic scope, such as broad
  authentication bypass, remote code execution, or high-value credential loss.
- **High:** practical unauthorized access, sensitive-data disclosure, privilege
  escalation, or major integrity/availability loss.
- **Medium:** meaningful exploitation with important prerequisites, constrained
  scope, or partial control failure.
- **Low:** limited security impact with a realistic abuse path.

Include prerequisites, reachability, scope, and existing mitigations.

## Confidence

- **High:** the complete path is demonstrated by code, configuration, or a safe
  reproduction.
- **Medium:** the path is strongly supported but one environment fact is absent.
- **Low:** use only for a labeled unverified surface, not a blocking finding.

Do not infer a vulnerability from a dangerous-looking API or scanner alert
alone. Check middleware, callers, parameter binding, installed versions,
reachability, and existing controls. Never test production, access real secrets,
or send exploit traffic without explicit authorization.
