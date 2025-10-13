# DevOps IaC Rules
- Terraform: `fmt -check`, `init`, `validate`, then `plan`. Never apply without approval.
- Use remote state with locking; separate workspaces per environment.
- Pulumi: prefer stacks per env; `preview` gated before `up`.