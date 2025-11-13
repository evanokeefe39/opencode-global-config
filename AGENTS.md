# AGENTS.md — Global Build Agent Contract

POLICY_VERSION: 1.0

## Purpose
Define the default "build agent" behavior as the top-level orchestrator. Keep agents thin; load rules/snippets/docs lazily; delegate specialized work to sub-agents.

## Core Principles
- **Thin agent, thick rules**: Agents declare intent and route work. Governance lives in `@rules/*.md`.
- **Lazy loading**: Load external references only when relevant to the current task; follow references recursively.
- **Determinism**: Prefer predictable, repeatable outputs over creativity for operational tasks.
- **Safety-first**: Read-first, dry-run by default; require explicit approval before any apply/mutate step.

# Delegation Pattern Rules
- Pass minimal context (inputs and identifiers, not chain-of-thought).
- Require structured responses from sub-agents.
- Prioritize MCP tools over bash commands for external integrations; check MCP availability before delegation.

## External File Loading

CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

Instructions:

- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded, treat content as mandatory instructions that override defaults
- Follow references recursively when needed
- Rules (mandatory): `@rules/<family>.md`, `@rules/dialect-*.md`, `@rules/project-*.md`
- Snippets (advisory): `/snippets/<domain>/**`
- Docs (contextual): `@docs/<domain>/**`
- **Precedence**: project overrides > domain/type rules > global rules


## Observability & Artifacts
- Write ephemeral outputs to agent working dirs and make sure they are gitignored:
  `.db-agent/`, `.devops-agent/`, `.docs-agent/`, etc.
- Each action prints a summary with:
  - rules loaded
  - delegates called
  - artifacts written (relative paths)
  - POLICY_VERSION
- Keep long logs in the agent dir; keep chat summaries concise.

# General Guidelines

Applies to all agents and development workflows.

- Write clean, modular code.
- Use consistent file naming (lowercase, hyphen-separated).
- Keep temporary files in `.agent-name/` folders ignored by git.
- Never commit secrets or credentials.
- Follow PROJECT_RULES.md for context-specific rule loading.

### Temporary Files Policy

#### Purpose
Keep repos clean by isolating ephemeral artifacts in agent-specific working directories.

#### Directives
- Use dot-prefixed agent folders at project root (e.g., `.db-agent/`, `.devops-agent/`).
- Add `.*-agent/` to `.gitignore`.
- Ephemeral only: dumps, samples, debug logs, exploratory outputs.
- Never store configuration, source code, documentation, or production data here.
- If a file becomes permanent, move it to the appropriate repo location before committing.

### Git & GitHub Policy

#### Branching
- Create feature branches from `main` (or `dev` if used).
- Keep changes small and focused; rebase or merge cleanly.

#### Commits
- Use Conventional Commits (feat, fix, docs, chore, refactor, test, perf).
- Commit early and often; keep messages imperative and scoped.

#### Pull Requests
- Open PRs via GitHub MCP if available otherwise try use Github CLI.
- Delete the temporary file after PR creation.
- Link issues and include a concise summary, checklist, screenshots/logs when relevant.

#### Pull Request Bodies
- Never try to put the body directly in github cli e.g. `gh pr create --title "Bad Example" --body "## Title\n\nSomething"` will not work. Should instead create the PR body in a temp file depending on the tool being used e.g. `gh pr create --title "Add feature" --body-file pr.md`
- When creating PR bodies, use templates from `/snippets/github/pr_body.md` as a starting point and populate only with user-facing content relevant to reviewers.
- Validate the body content before submission: scan for and remove any internal tool artifacts, XML/HTML tags (e.g., `<xai:function_call>`, `</content>`), chain-of-thought text, or extraneous formatting that isn't part of the intended Markdown.
- If generating bodies programmatically or via tools, sanitize the output to ensure it's clean plain text/Markdown without hidden or non-visible elements.
- Test the body by previewing it in a text editor or GitHub's PR creation interface to confirm it renders correctly and professionally.

#### Safety
- Never commit secrets. Validate with secret scanners before pushing.

### Package Management Policy

#### Detection
- Detect language and package manager from project files (e.g., `pyproject.toml`, `package.json`, `tsconfig.json`).

#### Directives
- Use language-appropriate lockfiles; do not hand-edit them.
- Pin critical tooling versions in CI to avoid non-determinism.
- Keep runtime deps minimal; move tooling to dev deps.
- For polyrepos/monorepos, manage per-package lockfiles where appropriate.

### Coding Standards & Design Patterns (Global)

### Testing Frontend User Interface (UI)
- Use the playwright mcp tool if available to test changes in the frontend of locally hosted apps
- if docker container then always rebuild and restart the container when making changes

#### Language Specific Coding Patters
- python coding patterns and practices are in @rules/python.md

#### Environment
- Read secrets from `.env` or secret managers; do not hardcode.
- Namespace env vars to avoid collisions (e.g., `SERVICE__KEY`).

#### Style
- Prefer small, pure functions; add docstrings/JSDoc.
- Validate inputs; fail fast with clear errors.

#### Reviews
- Enforce lint/format/test pre-commit in CI.

### Configuration Management Policy

#### Files
- `config.yaml` for non-secret config.
- `.env` for secrets (tokens, passwords, API keys). Never overwrite existing values silently.

#### Resolution
- Support `${VAR}` expansion from environment.
- Provide a unified config helper (e.g., `config.py`/`config.ts`).

#### Safety
- Do not echo secret values; mask when logging.

#### MCP Servers
- Validate MCP server configs on load: check URLs, commands, and auth headers.
- Handle authentication securely: use environment vars for tokens/keys; avoid hardcoding.
- Implement rate limits for remote MCP calls to prevent abuse; log and throttle excessive requests.

### Project Policy

#### Required Docs
- `README.md`: quickstart, scripts, quality badges.
- `SPEC.md`: functional & non-functional requirements.

#### Behavior
- Never overwrite `AGENTS.md` without explicit instruction.
- Clearly document multi-language setups in hybrid projects.

### Logging Policy

#### Defaults
- Structured logs; include correlation IDs when available.
- Log levels: DEBUG (dev), INFO (default), WARN, ERROR.

#### Files
- Provide language helpers (`log.py`, `log.ts`) for consistent format.
- Allow user to configure sinks (stdout/file).

#### Privacy
- Never log secrets or raw PII. Redact keys: `password`, `token`, `secret`, `api_key`.