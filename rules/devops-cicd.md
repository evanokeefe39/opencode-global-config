# DevOps CI/CD Rules
- Keep workflows least-privilege (permissions: read-all, write only when needed).
- Cache responsibly (node, pip) with keys including lockfiles.
- Separate jobs: lint → test → build → deploy; guard deploy on branch/env and manual approval.