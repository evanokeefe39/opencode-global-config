# Temporary Files Policy

## Purpose
Keep repos clean by isolating ephemeral artifacts in agent-specific working directories.

## Directives
- Use dot-prefixed agent folders at project root (e.g., `.db-agent/`, `.devops-agent/`).
- Add `.*-agent/` to `.gitignore`.
- Ephemeral only: dumps, samples, debug logs, exploratory outputs.
- Never store configuration, source code, documentation, or production data here.
- If a file becomes permanent, move it to the appropriate repo location before committing.
