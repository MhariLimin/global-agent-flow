# Claude Code installation

Copy the hook definition from `settings.example.json` into the consuming
repository's `.claude/settings.json` and adjust the component path.

The hook runs after a successful edit. A diagnostic failure returns exit code
`2`, making the feedback visible to Claude; it cannot undo the completed edit.
Keep checks fast and side-effect-free.

Reference: https://code.claude.com/docs/en/hooks-guide
