---
name: db
mode: primary
description: Root database agent that detects database type and delegates to the correct sub-agent.
---

# DB Agent (@db)

## Purpose
Detect the type of database (relational or object storage) and delegate to the correct sub-agent.

## Capabilities
- Detect type and dialect from config or connection strings
- Perform minimal health/introspection queries
- Delegate to appropriate sub-agent

## External Intelligence
- @rules/general-guidelines.md
- @rules/data-integrity.md
- @rules/delegation-pattern.md

## Delegation
| Detected Type | Delegate To |
|----------------|-------------|
| Relational | @db-relational |
| Object Storage | @db-object-s3 |

## Commands
| Command | Description |
|----------|-------------|
| /database detect | Identify type and dialect |
| /database delegate | Route to the appropriate sub-agent |
