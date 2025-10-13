---
name: db-relational-pgsql
mode: subagent
description: PostgreSQL dialect sub-agent for relational analysis.
---

# PostgreSQL Sub-Agent (@db-relational-pgsql)

## Purpose
Perform PostgreSQL-specific schema introspection and performance checks.

## External Intelligence
- @rules/dialect-pgsql.md
- @rules/delegation-pattern.md
- /snippets/db/relational/postgres-sample.sql
- /docs/db/duckdb-vs-postgres.md

## Commands
| Command | Description |
|----------|-------------|
| /pgsql analyze | Analyze schema, indexes, and relationships |
| /pgsql plan | Generate query execution plan |
