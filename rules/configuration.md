# Configuration Management Policy

## Files
- `config.yaml` for non-secret config.
- `.env` for secrets (tokens, passwords, API keys). Never overwrite existing values silently.

## Resolution
- Support `${VAR}` expansion from environment.
- Provide a unified config helper (e.g., `config.py`/`config.ts`).

## Safety
- Do not echo secret values; mask when logging.

## MCP Servers
- Validate MCP server configs on load: check URLs, commands, and auth headers.
- Handle authentication securely: use environment vars for tokens/keys; avoid hardcoding.
- Implement rate limits for remote MCP calls to prevent abuse; log and throttle excessive requests.
