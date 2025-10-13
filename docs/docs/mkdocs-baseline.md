# MkDocs Baseline
A minimal mkdocs.yml the docs agent can extend when needed:

```yaml
site_name: Project Documentation
theme:
  name: material
  features:
    - navigation.tabs
    - content.code.copy
    - content.code.annotate
plugins:
  - search
  - mkdocstrings
markdown_extensions:
  - toc:
      permalink: true
  - admonition
  - codehilite
  - footnotes
nav:
  - Home: index.md
  - Guides:
      - Getting Started: guides/getting-started.md
  - Reference:
      - API: api/index.md
```
