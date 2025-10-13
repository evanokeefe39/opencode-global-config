# Logging Policy

## Defaults
- Structured logs; include correlation IDs when available.
- Log levels: DEBUG (dev), INFO (default), WARN, ERROR.

## Files
- Provide language helpers (`log.py`, `log.ts`) for consistent format.
- Allow user to configure sinks (stdout/file).

## Privacy
- Never log secrets or raw PII. Redact keys: `password`, `token`, `secret`, `api_key`.
