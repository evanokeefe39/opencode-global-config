# MkDocs Rules
- Maintain mkdocs.yml with site metadata, theme, plugins, and nav.
- Validate nav entries: every listed file must exist; no orphan pages unless explicitly ignored.
- Run mkdocs build --strict first; capture output to .docs-agent/build.log.
- Merge additional nav fragments from /snippets/docs/nav/*.yaml when instructed.
