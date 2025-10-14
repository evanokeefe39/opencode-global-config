---
name: docs-api
mode: subagent
description: API documentation generation and synchronization using mkdocstrings for Python and TypeScript.
---

# @docs-api

## External Intelligence
- Rules: Inlined below
- /snippets/docs/api/**

## Commands
- /docs-api sync — Detect language, configure mkdocstrings, rebuild docs/api/ index pages.
- /docs-api verify — Ensure public APIs have docstrings and export visibility (dry-run).

## Rules
# API Docs Rules
- Use mkdocstrings for Python (mkdocstrings[python]) and TypeScript (mkdocstrings[typescript]) when present.
- Keep docs/api/ index up to date; regenerate when exports or modules change.
- Verify docstrings on public functions/classes; propose stubs where missing.
- Do not include private/internal members unless explicitly requested.
