---
name: docs-style
mode: subagent
description: Markdown structure, headings hierarchy, front-matter normalization, and link hygiene.
---

# @docs-style

## External Intelligence
- Rules: Inlined below
- /snippets/docs/common/**

## Commands
- /docs-style lint — Check headings depth, sentence-case titles, fenced code blocks, and internal links.
- /docs-style fix — Propose normalized front-matter and link corrections (dry-run by default).

## Rules
# Markdown Style Rules
- Top-level # title equals file name in sentence case; subsequent headings start at ##.
- Max heading depth: ###.
- Add front-matter when useful (title, description, tags); avoid noise.
- Normalize relative links; prefer .md with anchors.
- Keep paragraphs ≤ 4 lines; introduce concepts before code examples.
