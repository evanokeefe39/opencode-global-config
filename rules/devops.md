# DevOps General Rules
- Read-first, plan-first. Dry-run by default.
- Use agent working dir `.devops-agent/` for ephemeral artifacts.
- Never echo secrets. Validate CI/CD secret references before use (`secrets.*`, `vars.*`).