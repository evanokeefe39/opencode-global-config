---
name: devops-vcs
mode: subagent
description: Version control and GitHub integration (branches, commits, PRs).
---

# @devops-vcs

## External Intelligence
- @rules/devops-vcs.md
- @rules/git-and-github.md
- /snippets/github/**
- /snippets/git/**

## Commands
- /ops-vcs init — initialize repo, .gitignore, baseline workflows (dry-run).
- /ops-vcs pr — open PR via GitHub MCP tools; use PR body template from snippets; cleanup temp files; bypass direct gh CLI calls.
- /ops-vcs enforce — check Conventional Commits and branch policy using GitHub MCP for repo validation.
