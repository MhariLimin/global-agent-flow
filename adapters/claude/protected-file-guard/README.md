# Claude Code installation

Copy the `hooks` block from `settings.example.json` into the consuming
repository's `.claude/settings.json`. Adjust the script path if the component is
installed elsewhere.

The adapter reads Claude's event JSON from standard input. Exit code `2`
blocks a protected write and returns the guard's reason to Claude.

Test the underlying component before enabling the hook. Use `/hooks` to confirm
registration and `disableAllHooks` in local settings when diagnosing hook
configuration.

Reference: https://code.claude.com/docs/en/hooks-guide
