# Context selection

Load context in layers and stop when the task is supported.

1. **Always-on truth:** repository instructions, manifest, and relevant status.
2. **Task entry point:** route, command, component, handler, failing test, or
   issue-linked spec.
3. **Immediate dependencies:** callers, state/data owner, contracts, and tests.
4. **Boundary context:** authentication/authorization, persistence, external
   service, migration, or deployment rules only when crossed.
5. **History:** resolved specs and Git history only when current code does not
   explain a decision.

Prefer targeted filename and symbol search. Record paths selected and why.
Exclude unrelated roadmap items, generated artifacts, dependency directories,
and real secret files.

## Evidence labels

- **Known:** directly supported by inspected code, config, test, or instruction.
- **Assumed:** reasonable inference required to draft the brief; state it.
- **Unknown:** cannot be determined locally and may need a decision or runtime
  evidence.

An unknown is blocking only when different answers produce materially different
implementations or public behavior.
