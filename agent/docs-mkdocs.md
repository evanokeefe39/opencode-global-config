---
name: docs-mkdocs
mode: subagent
description: MkDocs-Material site management. Validates navigation, metadata, and performs strict builds.
---

# @docs-mkdocs

## External Intelligence
- Rules: Inlined below
- /snippets/docs/nav/**
- /snippets/docs/common/**

## Commands
- /docs-mk build — Validate mkdocs.yml, merge nav fragments, run `mkdocs build --strict`.
- /docs-mk serve — Optional local preview command suggestion (`mkdocs serve`).

## Output
- Summary includes added/removed pages, broken links, and artifacts written to .docs-agent/.

## Rules
# MkDocs Rules
- Maintain mkdocs.yml with site metadata, theme, plugins, and nav.
- Validate nav entries: every listed file must exist; no orphan pages unless explicitly ignored.
- Run mkdocs build --strict first; capture output to .docs-agent/build.log.
- Merge additional nav fragments from /snippets/docs/nav/*.yaml when instructed.
