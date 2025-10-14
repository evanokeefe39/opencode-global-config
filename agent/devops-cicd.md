---
name: devops-cicd
mode: subagent
description: CI/CD workflow authoring and validation (GitHub Actions).
---

# @devops-cicd

## External Intelligence
- Rules: Inlined below
- /snippets/devops/workflows/**
- @rules/logging.md

## Commands
- /ops-ci init — scaffold ci.yml/deploy.yml from snippets (dry-run).
- /ops-ci validate — lint/validate workflows, check permissions and secrets usage.

## Rules
# DevOps CI/CD Rules
- Keep workflows least-privilege (permissions: read-all, write only when needed).
- Cache responsibly (node, pip) with keys including lockfiles.
- Separate jobs: lint → test → build → deploy; guard deploy on branch/env and manual approval.
