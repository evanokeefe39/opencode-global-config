# Security Rules

Defines mandatory security standards for all codebases and agents.

- Never store secrets in plaintext.
- Use environment variables or vaults for secrets.
- CI/CD pipelines must use least-privilege permissions.
- Validate Docker images with vulnerability scans.
- Require code review for all security-relevant changes.
- Enforce MCP tool permissions: restrict read-only access for sensitive repos; audit MCP server interactions for data leakage.
