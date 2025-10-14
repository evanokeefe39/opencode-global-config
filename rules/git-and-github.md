# Git & GitHub Policy

## Branching
- Create feature branches from `main` (or `dev` if used).
- Keep changes small and focused; rebase or merge cleanly.

## Commits
- Use Conventional Commits (feat, fix, docs, chore, refactor, test, perf).
- Commit early and often; keep messages imperative and scoped.

## Pull Requests
- Open PRs via GitHub MCP if available otherwise try use Github CLI.
- Never try to put the body directly in github cli e.g. `gh pr create --title "Bad Example" --body "## Title\n\nSomething"` will not work. Create the PR body in a temp file e.g. `gh pr create --title "Add feature" --body-file pr.md`
- Delete the temporary file after PR creation.
- Link issues and include a concise summary, checklist, screenshots/logs when relevant.

## Safety
- Never commit secrets. Validate with secret scanners before pushing.
