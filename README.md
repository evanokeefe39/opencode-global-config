# OpenCode

An interactive CLI tool that helps users with software engineering tasks.

## Quickstart

To get help with using OpenCode, run `/help`.

For feedback or issues, please report at https://github.com/sst/opencode/issues.

## Scripts

- `/help`: Get help with using opencode

## Quality Badges

<!-- Add quality badges here, e.g., build status, coverage, etc. -->

## Architecture

OpenCode employs a modular agent-based architecture designed for extensibility and safety. The system uses thin agents that orchestrate tasks and delegate specialized work to sub-agents, while governance and standards are maintained in rules files. This separation allows for deterministic, repeatable operations with lazy loading of resources.

## Layout

This repository tracks the global configuration for OpenCode, structured as follows:

- `agents/`: Markdown files defining sub-agents (database, DevOps, documentation) and their capabilities.
- `rules/`: Policy and standards files governing behavior, naming conventions, and best practices.
- `snippets/`: Reusable code snippets, templates, and licenses for common tasks.
- `AGENTS.md`: The global build agent contract outlining core principles and delegation patterns.
- `opencode.json`: MCP server configuration.

## Methodology

The configuration follows a "thin agent, thick rules" methodology where agents focus on tool orchestration and intent declaration, while rules handle standards and governance. Key principles include:

- **Lazy Loading**: Rules, snippets, and docs are loaded only when relevant to the current task.
- **Delegation**: Agents pass minimal context to sub-agents, avoiding cycles and ensuring termination.
- **Safety-First**: Default read-only permissions with explicit escalation for mutations.
- **Determinism**: Prioritizing predictable outputs over creativity for operational tasks.

| Concern                                           | Lives in Agent | Lives in Rules |
| ------------------------------------------------- | -------------- | -------------- |
| Which tools are allowed (`git`, `psql`, `mkdocs`) | ✅              | ❌              |
| Command syntax and orchestration                  | ✅              | ❌              |
| Standards, naming conventions, required files     | ❌              | ✅              |
| Security, versioning, or release policies         | ❌              | ✅              |
| How to detect context (language, framework)       | ✅              | ❌              |
| What constitutes best practice for that context   | ❌              | ✅              |
