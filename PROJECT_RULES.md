# Project Rules and Execution Policy

Defines how agents and contributors should load and apply rules dynamically across the workspace.

---

## 1. Rule Loading Model

**CRITICAL:**  
Rules are modular. Do *not* preload all `.md` or `@rules/` files. Load them only when the task context requires it.

### Instructions
- When you see a reference like `@rules/<file>.md`, use the `read` tool to load it.
- When loaded, treat its contents as **mandatory overrides** of any defaults.
- Follow linked references recursively if they appear inside a loaded rule file.
- Do **not** cache irrelevant rule files in memory — reload fresh copies on context switch.

---

## 2. Rule Categories

| Category | Directory | Description |
|-----------|------------|-------------|
| General | `@rules/general-guidelines.md` | Core behaviors that apply to all workflows |
| Security | `@rules/security.md` | Secret management, deployment hardening, and access control policies |
| Versioning | `@rules/versioning.md` | Tagging, release, and changelog standards |
| TypeScript | `@docs/typescript-guidelines.md` | Language-specific conventions |
| React | `@docs/react-patterns.md` | Component design and hook usage |
| API | `@docs/api-standards.md` | REST and error-handling conventions |
| Testing | `@test/testing-guidelines.md` | Unit, integration, and coverage expectations |

---

## 3. Immediate Requirements

The following rule must be **loaded at startup for all agents**:

```
@rules/general-guidelines.md
```

All other rule files should be fetched only when relevant to the task or file type being processed.

---

## 4. Development Guidelines

### TypeScript
Refer to: `@docs/typescript-guidelines.md`  
- Enforce strict typing (`"strict": true` in tsconfig)  
- Prefer interfaces over types for API contracts  
- Avoid default exports; use named exports for clarity

### React
Refer to: `@docs/react-patterns.md`  
- Use function components and hooks  
- Keep components pure and composable  
- Co-locate component CSS or style files

### API Design
Refer to: `@docs/api-standards.md`  
- Follow REST conventions  
- Include versioning (e.g., `/v1/users`)  
- Use structured error responses `{ code, message, details }`

### Testing
Refer to: `@test/testing-guidelines.md`  
- Minimum 80% coverage threshold  
- Use snapshot testing sparingly  
- Validate all API contracts with integration tests

---

## 5. Governance Notes

- All rule files are version-controlled under `/rules/`, `/docs/`, and `/test/`.
- Any change to rule files requires a short changelog entry in `/rules/CHANGELOG.md`.
- When merging PRs, the DevOps agent validates modified rule files against Markdown linting and structure rules.

---

## 6. Example Behavior

| Agent | When Triggered | Rules Loaded |
|--------|----------------|--------------|
| `@devops` | building or deploying | `/rules/general-guidelines.md` |
| `@docs` | updating MkDocs site | `/rules/general-guidelines.md`, `/docs/api-standards.md` |
| `@security` | scanning codebase | `/rules/general-guidelines.md`, `/rules/security.md` |
| `@ts` (TypeScript agent) | editing `.ts` files | `/rules/general-guidelines.md`, `/docs/typescript-guidelines.md` |

---

## 7. Future Enhancements

- Add `@rules/security.md` for compliance and vulnerability-handling  
- Add `@rules/versioning.md` to govern release tagging and changelog format  
