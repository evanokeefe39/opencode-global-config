# Package Management Policy

## Detection
- Detect language and package manager from project files (e.g., `pyproject.toml`, `package.json`, `tsconfig.json`).

## Directives
- Use language-appropriate lockfiles; do not hand-edit them.
- Pin critical tooling versions in CI to avoid non-determinism.
- Keep runtime deps minimal; move tooling to dev deps.
- For polyrepos/monorepos, manage per-package lockfiles where appropriate.
