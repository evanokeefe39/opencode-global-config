# DevOps Build Rules
- Use multi-stage Docker builds; run as non-root; copy only necessary artifacts.
- Always include `.dockerignore` to reduce context size.
- Tag images with branch+sha and `latest` for default branch; push only on approval.