# Docker Best Practices (2025)

This document captures overarching Docker best practices as well as explicit, implementation-ready examples and references. Each protocol or tool is included with enough detail that a developer can search for details, similar to how one looks up 'conventional commits' or 'gitflow' for version control policies.

---
## 1. General Principles
- **Minimize Image Size**: Always use minimal base images (e.g., alpine, distroless), multi-stage builds, and `.dockerignore` to shrink context and reduce attack surface.
- **Immutable Infrastructure**: Treat images as immutable. Rebuild rather than patch running containers.
- **Version Pinning**: Use explicit image tags, avoid `latest`, and specify versions for all dependencies.
- **Automate and Integrate**: Use CI/CD integrations to automate building, scanning, and deploying container images. 

## 2. Dockerfile Best Practices
- **Multi-Stage Builds**: Separate build and runtime dependencies to produce smaller, secure images (see multi-stage examples below).
- **Run as Non-Root**: Always specify a non-root `USER` in containers for least privilege. Only elevate as needed.
- **COPY over ADD**: Prefer `COPY`; reserve `ADD` only for remote or archive extraction.
- **Use .dockerignore**: Exclude unnecessary directories (like `.git`, `node_modules/`, build output) to speed builds, shrink images, and reduce risk.
- **Scan for Vulnerabilities**: Integrate image scans (e.g., Trivy, Docker Scan, Snyk) in your pipelines.
- **Secrets Management**: Never bake credentials into images. Use build-time secrets, Docker secrets, or mount external vaults at runtime.

### Example (Node.js, Multi-Stage)
```dockerfile
FROM node:22-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine AS production
WORKDIR /usr/share/nginx/html
COPY --from=build /app/build .
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

### Example (Go, Multi-Stage)
```dockerfile
FROM golang:1.23 AS build
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o main .
FROM scratch
COPY --from=build /app/main /main
ENTRYPOINT ["/main"]
```

### Example (Python, pip + venv)
```dockerfile
FROM python:3-slim AS build
WORKDIR /app
RUN python -m venv .venv
COPY requirements.txt ./
RUN .venv/bin/pip install -r requirements.txt
COPY . .

FROM python:3-slim AS runtime
WORKDIR /app
COPY --from=build /app /app
ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["python", "main.py"]
```


## 3. .dockerignore Patterns
- Mirrors `.gitignore` for your build context (syntax: https://docs.docker.com/build/concepts/context/#dockerignore-file).
- **Example: Node.js**
```
**/node_modules/
.git
npm-debug.log
.env
*.test.js
```
- **Example: Python**
```
__pycache__
*.pyc
*.pyo
*.pyd
.git
.env
```
- Use `!` for exceptions (e.g., `!README.md`).

## 4. Docker Compose Best Practices
- **Version & Modularity**: Always specify a schema version, keep each service modular, and document each section.
- **Named Volumes**: Use for persistence; define at the bottom of the file for readability.
- **Explicit Networks**: Define and isolate networks for services as needed.
- **Environment Variables**: Use `.env` files for configuration and secrets—never hardcode.
- **Profiles/Overrides**: Use profiles or multiple compose files (like `docker-compose.prod.yml`) for environment-specific configs.
- **Resource Limits**: Specify `deploy.resources` to limit memory and CPU for each service (where supported).
- **depends_on & Healthchecks**: Use `depends_on` and/or `healthcheck` rather than manual sleep/wait logic for startup ordering.

### Example: docker-compose.yml
```yaml
version: '3.9'
services:
  web:
    build: .
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
  db:
    image: postgres:15
    volumes:
      - db_data:/var/lib/postgresql/data
volumes:
  db_data:
```

## 5. Security & Operations
- **Resource Limits**: Apply memory/cpu constraints (`--memory`, `--cpus` for `docker run`, or `deploy.resources` in Compose).
- **Read-Only Filesystem**: Use `--read-only` or `read_only: true` in Compose to restrict writes except for specified mounts.
- **User Namespaces & Capabilities**: Drop unneeded Linux capabilities and enable user namespaces for isolation.
- **Docker Content Trust**: Enable DCT (`DOCKER_CONTENT_TRUST=1`) for signature verification.
- **Audit/Monitor**: Centralize logging and monitor container activity for anomalous behavior.
- **Patch Regularly**: Update base images and host OS regularly; rebuild images to pick up fixes.


## 6. Canonical Protocols / Patterns to Reference
- **Multi-Stage Builds**: See Docker docs on "multi-stage builds" for multi-language guidance (https://docs.docker.com/build/building/multi-stage/).
- **dockerignore Syntax**: https://docs.docker.com/build/concepts/context/#dockerignore-file
- **Compose Environment Variables**: https://docs.docker.com/compose/environment-variables/env-file/
- **Secret Handling**: https://docs.docker.com/engine/swarm/secrets/
- **Image Scanning**: Trivy, Snyk, Docker Scan—you can find setup docs on each
- **Seccomp & AppArmor Profiles**: Search for "Docker seccomp profile", "Docker AppArmor best practices"
- **Resource Limits**: https://docs.docker.com/config/containers/resource_constraints/

---
For context, these best practices are aligned to modern 2025 recommendations and are updated regularly per Docker's own [official docs](https://docs.docker.com/build/building/best-practices/) and leading industry guides. For more details on any section, search the reference URLs provided above. 
s