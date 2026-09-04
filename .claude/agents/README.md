# .claude/agents

The four core C-suite agents live canonically in [`../../agents/`](../../agents/)
so they carry the Scope Creep manifest schema.

**v1 task:** generate Claude Agent SDK subagent definitions here (with the
SDK's expected `name`/`description`/`tools` front-matter and the agent's body as
the system prompt) from those canonical files, so the harness can invoke them
directly. Kept as a deliberate wiring step rather than shipping possibly-malformed
subagent files on day 0.
