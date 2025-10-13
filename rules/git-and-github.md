# Git & GitHub Policy

## Branching
- Create feature branches from `main` (or `dev` if used).
- Keep changes small and focused; rebase or merge cleanly.

## Commits
- Use Conventional Commits (feat, fix, docs, chore, refactor, test, perf).
- Commit early and often; keep messages imperative and scoped.

## Pull Requests
- Open PRs via GitHub CLI when possible (`gh pr create`).
- Generate PR bodies from a temporary markdown file and pass with `--body-file`.
- Delete the temporary file after PR creation.
- Link issues and include a concise summary, checklist, screenshots/logs when relevant.

## Safety
- Never commit secrets. Validate with secret scanners before pushing.
