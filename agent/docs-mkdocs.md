---
name: docs-mkdocs
mode: subagent
description: MkDocs-Material site management. Validates navigation, metadata, and performs strict builds.
---

# @docs-mkdocs

## External Intelligence
- @rules/docs-mkdocs.md
- /snippets/docs/nav/**
- /snippets/docs/common/**

## Commands
- /docs-mk build — Validate mkdocs.yml, merge nav fragments, run `mkdocs build --strict`.
- /docs-mk serve — Optional local preview command suggestion (`mkdocs serve`).

## Output
- Summary includes added/removed pages, broken links, and artifacts written to .docs-agent/.
