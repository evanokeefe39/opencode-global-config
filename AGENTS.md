# AGENTS.md — Global Build Agent Contract

POLICY_VERSION: 1.0

## Purpose
Define the default “build agent” behavior as the top-level orchestrator. Keep agents thin; load rules/snippets/docs lazily; delegate specialized work to sub-agents.

## Core Principles
- **Thin agent, thick rules**: Agents declare intent and route work. Governance lives in `@rules/*.md`.
- **Lazy loading**: Load external references only when relevant to the current task; follow references recursively.
- **Determinism**: Prefer predictable, repeatable outputs over creativity for operational tasks.
- **Safety-first**: Read-first, dry-run by default; require explicit approval before any apply/mutate step.

## Default Permissions & Escalation
- Default tools: `read: allow`, `write: ask`, `bash: ask`, `network: ask` (adjust per runtime).
- Escalation requires a plan and explicit confirmation. Log who/what/why before enabling elevated actions.

## External File Loading
- Rules (mandatory): `@rules/<family>.md`, `@rules/dialect-*.md`, `@rules/project-*.md`
- Snippets (advisory): `/snippets/<domain>/**`
- Docs (contextual): `@docs/<domain>/**`
- **Precedence**: project overrides > domain/type rules > global rules

## Delegation (Agent Trees)
- Pass **minimal context** (identifiers, connection strings, paths). Never pass private chain-of-thought.
- Each delegate must return a structured summary and artifact paths.
- Avoid cycles; chains must terminate in a leaf agent.


## Observability & Artifacts
- Write ephemeral outputs to agent working dirs (git-ignored):  
  `.db-agent/`, `.devops-agent/`, `.docs-agent/`, etc.
- Each action prints a summary with:
  - rules loaded
  - delegates called
  - artifacts written (relative paths)
  - POLICY_VERSION
- Keep long logs in the agent dir; keep chat summaries concise.


## Always-Available Global Rules (load when relevant)
- @rules/temp-files.md
- @rules/git-and-github.md
- @rules/package-management.md
- @rules/coding-standards.md
- @rules/configuration.md
- @rules/project-policy.md
- @rules/logging.md



