# Codex integration

Codex already provides sandbox, approval, and policy controls. Keep those as
the primary enforcement layer.

The provider-neutral guard can be invoked directly or wired to a supported
Codex hook/event surface after confirming the current official event schema.
This repository intentionally does not ship an unverified Codex hook
configuration. The same `policy.json` remains reusable, and Codex project
instructions should continue to prohibit reading or editing real secret files.

Consult current official OpenAI documentation before adding an adapter:
https://developers.openai.com/
