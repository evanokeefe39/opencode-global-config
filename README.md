# 🚀 OpenCode

**Streamline your software engineering workflow with AI-powered agents and MCP integrations.**

OpenCode is an interactive CLI tool that enhances productivity by automating tedious operational tasks, allowing developers to focus on deep coding work. It integrates with Context7, GitHub, and Notion MCPs to manage work across projects, while specialized agents handle DevOps, database operations, documentation, and project management.

## ✨ Key Features

- **🔗 MCP Integrations**: Seamlessly connect with Context7 (documentation), GitHub (version control), and Notion (project management) for unified workflow management
- **🤖 Specialized Agents**: Dedicated agents for DevOps, database backends, documentation, and product management to eliminate administrative overhead
- **🎯 Focus on Coding**: Automate repetitive tasks so you can dedicate large blocks of time to complex coding challenges
- **🛡️ Safety-First Architecture**: Thin agents with thick governance rules ensure secure, deterministic operations
- **📦 Modular Design**: Extensible agent-based system with lazy loading for optimal performance

## 🏗️ Architecture

OpenCode employs a modular agent-based architecture designed for extensibility and safety. Thin orchestrator agents delegate specialized work to sub-agents, while governance lives in rules files. This separation enables deterministic, repeatable operations with on-demand resource loading.

## 📁 Repository Structure

This repository contains the global configuration for OpenCode:

- `agents/` - Markdown files defining sub-agents (database, DevOps, documentation, Notion) and their capabilities
- `snippets/` - Reusable code snippets, templates, and licenses for common tasks
- `AGENTS.md` - Global build agent contract with core principles and delegation patterns
- `opencode.json.example` - Example MCP server configuration (real config is gitignored for security)

## 🤖 Agent Patterns

Each agent follows a modular structure designed for extensibility and safety:

- **Rules**: Define policies and standards (e.g., database normalization, CI/CD workflows, documentation style)
- **Snippets/Templates**: Provide concrete examples and reusable code (e.g., SQL queries, Dockerfiles, Notion JSON templates)
- **Domain Documentation**: Describe best practices and how-to guides (e.g., API docs workflows, versioning rules)

### External File Loading

To maintain modularity, agents use **lazy loading** for external references:

- **Lazy Loading**: Load rules, snippets, and docs only when relevant to the current task (e.g., `@rules/general.md` for general policies).
- **References**: Follow recursive references as needed; treat loaded content as mandatory instructions overriding defaults.
- **Categories**:
  - **Rules** (mandatory): `@rules/<family>.md`, `@rules/dialect-*.md`, `@rules/project-*.md`
  - **Snippets** (advisory): `/snippets/<domain>/**`
  - **Docs** (contextual): `@docs/<domain>/**`
- **Precedence**: Project-specific overrides > domain/type rules > global rules.

This approach ensures efficiency and adaptability. For full details, see the [OpenCode Rules Documentation](https://opencode.ai/docs/rules/).

## 🚀 Quickstart

1. **Install OpenCode**: Follow the installation guide (link TBD)
2. **Configure MCPs**: Copy `opencode.json.example` to `opencode.json` and add your API keys
3. **Get Help**: Run `/help` for assistance
4. **Start Coding**: Let agents handle the ops while you focus on development

## 📊 Methodology

The "thin agent, thick rules" approach separates concerns:

| Concern                                           | Agent Responsibility | Rules Responsibility |
| ------------------------------------------------- | -------------------- | -------------------- |
| Tool orchestration & intent declaration           | ✅                    | ❌                    |
| Standards, naming, security policies              | ❌                    | ✅                    |
| Context detection (language/framework)            | ✅                    | ❌                    |
| Best practices for specific contexts              | ❌                    | ✅                    |

Key principles:
- **Lazy Loading**: Resources loaded only when needed
- **Delegation**: Minimal context passing to sub-agents
- **Safety-First**: Read-only by default with explicit mutation approval
- **Determinism**: Predictable outputs for operational tasks

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines (link TBD) and report issues at [GitHub Issues](https://github.com/sst/opencode/issues).

## 📈 Quality Badges

<!-- Add quality badges here, e.g., build status, coverage, etc. -->
