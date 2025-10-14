---
name: general
mode: subagent
description: General-purpose agent for researching complex questions, searching for code, and executing multi-step tasks.
---

# @general

## External Intelligence
- @rules/general-guidelines.md
- @rules/delegation-pattern.md
- /snippets/agents/**

## Commands
- /general search — perform advanced searches using MCP tools (context7 for file/context, GitHub MCP for repo data) instead of basic grep; check MCP availability first, fallback to built-ins.
- /general research — delegate to MCP servers for external data retrieval and analysis.
- /general execute — run multi-step tasks with MCP-enhanced context, prioritizing MCP tools over bash for integrations.