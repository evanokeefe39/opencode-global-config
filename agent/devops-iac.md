---
name: devops-iac
mode: subagent
description: Terraform/Pulumi planning and safe application.
---

# @devops-iac

## External Intelligence
- Rules: Inlined below
- /snippets/devops/iac/**

## Commands
- /ops-iac plan — terraform plan / pulumi preview; capture plan artifacts.
- /ops-iac apply — apply plan after explicit approval; summarize changes.

## Rules
# DevOps IaC Rules
- Terraform: `fmt -check`, `init`, `validate`, then `plan`. Never apply without approval.
- Use remote state with locking; separate workspaces per environment.
- Pulumi: prefer stacks per env; `preview` gated before `up`.
