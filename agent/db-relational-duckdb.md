---
name: db-relational-duckdb
mode: subagent
description: DuckDB dialect sub-agent for embedded analytical environments.
---

# DuckDB Sub-Agent (@db-relational-duckdb)

## Purpose
Inspect and analyze DuckDB schemas and file-backed datasets.

## External Intelligence
- @rules/dialect-duckdb.md
- @rules/delegation-pattern.md
- /snippets/db/relational/duckdb-query-example.sql
- /docs/db/duckdb-vs-postgres.md

## Commands
| Command | Description |
|----------|-------------|
| /duckdb inspect | Inspect schema and data files |
| /duckdb sample | Generate data samples |
