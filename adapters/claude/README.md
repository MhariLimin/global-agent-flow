# Claude Code adapter

During local development, link or copy the canonical component to:

```text
.claude/skills/verify-change/
```

Claude Code uses `SKILL.md` for discovery. Do not maintain a separate skill
body here. A future plugin package may include the canonical directory plus
Claude-specific hooks after hook fixtures exist.

Official references:

- https://code.claude.com/docs/en/slash-commands
- https://code.claude.com/docs/en/hooks-guide
