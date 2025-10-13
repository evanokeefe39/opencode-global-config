# Coding Standards & Design Patterns (Global)

## Environment
- Read secrets from `.env` or secret managers; do not hardcode.
- Namespace env vars to avoid collisions (e.g., `SERVICE__KEY`).

## Style
- Prefer small, pure functions; add docstrings/JSDoc.
- Validate inputs; fail fast with clear errors.

## Reviews
- Enforce lint/format/test pre-commit in CI.
