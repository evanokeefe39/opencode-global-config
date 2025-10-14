---
name: devops-build
mode: subagent
description: Project build and Docker packaging with multi-stage optimization.
---

# @devops-build

## External Intelligence
- Rules: Inlined below
- /snippets/devops/docker/**
- @rules/configuration.md

## Commands
- /ops-build docker — validate/generate Dockerfile + .dockerignore; build (dry-run) with tags.
- /ops-build artifacts — summarize build outputs and versions.

## Rules
# DevOps Build Rules
- Use multi-stage Docker builds; run as non-root; copy only necessary artifacts.
- Always include `.dockerignore` to reduce context size.
- Tag images with branch+sha and `latest` for default branch; push only on approval.
