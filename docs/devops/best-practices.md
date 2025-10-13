# DevOps Best Practices
- Prefer deterministic builds and pinned tooling in CI.
- Keep secrets out of repos; use managers (GH Secrets, Vault, SSM).
- Separate concerns: build, test, package, deploy stages.
- Record artifact digests/tags in release notes or build logs.