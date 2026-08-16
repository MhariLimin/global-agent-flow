# Codex adapter

Install or link the canonical `components/skills/verify-change` folder into a
Codex skills location supported by the current environment. The included
`agents/openai.yaml` provides UI metadata while `SKILL.md` remains the source
of procedural behavior.

Keep repository-wide facts in the consuming project's `AGENTS.md`, not in the
shared skill. Consult current official OpenAI documentation before adding
Codex-specific automation or distribution metadata:

- https://developers.openai.com/
