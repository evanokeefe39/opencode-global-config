---
name: db-relational
mode: subagent
description: Handles relational databases and delegates to dialect sub-agents.
---

# Relational Database Sub-Agent (@db-relational)

## Purpose
Handle relational database standards and delegate to dialect-specific sub-agents.

## External Intelligence
- @rules/db-relational.md
- @rules/delegation-pattern.md
- /snippets/agents/delegation-pattern.md
- /docs/db/relational-best-practices.md

## Delegation
| Dialect | Delegate To |
|----------|--------------|
| PostgreSQL | @db-relational-pgsql |
| DuckDB | @db-relational-duckdb |

## Commands
| Command | Description |
|----------|-------------|
| /relational inspect | Basic schema introspection |
| /relational delegate | Forward to dialect sub-agent |
