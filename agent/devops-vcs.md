---
name: devops-vcs
mode: subagent
description: Version control and GitHub integration (branches, commits, PRs).
---

# @devops-vcs

## External Intelligence
- @rules/git-and-github.md
- Rules: Inlined below
- /snippets/github/**
- /snippets/git/**

## Commands
- /ops-vcs init — initialize repo, .gitignore, baseline workflows (dry-run).
- /ops-vcs pr — open PR via GitHub MCP tools; use PR body template from snippets; cleanup temp files; bypass direct gh CLI calls.
- /ops-vcs enforce — check Conventional Commits and branch policy using GitHub MCP for repo validation.

## Rules
# DevOps VCS Rules
- Use and enforce Conventional Commits via commitlint in CI and (optionally) husky.
- Prefer PRs from feature branches; require reviews for protected branches.
- Use PR body templates; reference issues in the footer (Closes #id).
- Use Github MCP tool instead of bash or cli
