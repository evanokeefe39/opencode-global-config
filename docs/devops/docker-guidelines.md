# Docker Guidelines
- Multi-stage builds; minimal base (alpine or distroless when feasible).
- Non-root runtime user; expose only required ports.
- Healthcheck and graceful shutdown; use `.dockerignore` rigorously.