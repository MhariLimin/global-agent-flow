# Claude Repository Guide

Read `AGENTS.md` for repository-wide rules. Read only the component being
changed and its direct references. Do not preload all examples or future design
documents.

Claude-specific distribution belongs in `adapters/claude/`; keep component
logic provider-neutral. Never weaken deterministic failures or safety gates to
make an agent workflow appear successful.
