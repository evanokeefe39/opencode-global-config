# AGENTS.md

## Temporary Files Policy
ALL temporary, ad-hoc, or sample data MUST go in agent-specific working folders (e.g., .db-agent/, .devops-agent/, etc.):

- **Location**: Agent-specific folders at project root, prefixed with a dot (e.g., .db-agent/ for the database agent)
- **Git Status**: Automatically ignored via .gitignore (add patterns like .*-agent/ to ignore all such folders)
- **Purpose**: Keep repository clean of non-essential files while providing isolated working areas for each sub-agent
- **Working Area Usage**: These folders serve as dedicated scratch spaces for agents to create and manage temporary files during operations. Agents must be instructed to move any files that become useful or permanent (e.g., finalized schemas, tested configurations) out of their working area and into appropriate main project directories before committing.

Files that BELONG in agent-specific folders:

- Database schema dumps (sample_schema_output.txt in .db-agent/)
- Test data exports (test_export.csv in relevant agent folder)
- Debug outputs (debug_results.json in relevant agent folder)
- Exploratory data analysis results
- Any file created for investigation that shouldn't be committed

Files that do NOT belong in agent-specific folders:

- Configuration files
- Source code
- Documentation
- Production data

## Utilities Policy
Place helper functions, scripts, or tools for repetitive development tasks in a `/utils` folder. These are not part of the application runtime but speed up developer workflows.

**Examples:**
- **Database helpers** → `utils/db_inspector.[py/ts]` for schema exploration
- **Health checks** → `utils/health_check.[py/ts]` for service verification
- **Build scripts** → Docker image builders, artifact packagers
- **Code quality tools** → Linting, formatting, test runners
- **Data sampling scripts** → Preview external data sources

For language-specific utilities, follow the relevant standards (e.g., Python or TypeScript specifics below).

## GitHub & Git Policy
- Use feature branches from `main` (default). If the user requests, migrate to new strategy.  
- Commit with [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).  
- Work only on `dev` or feature branches. Confirm with user if multiple feature branches are active.  
- Always use Git. If missing, init repo with `.gitignore` (tailored to project language, e.g., Python or TypeScript patterns), README, and LICENSE.  
- Use **GitHub CLI (`gh`)** if available to publish branches, open pull requests, and manage repo interactions. Fall back to the GitHub web UI if CLI is unavailable.  
- When generating the body of the pull request description, use a temporary markdown file and the --body-file argument, delete the markdown file when finished.

## Package Management Policy
- Detect project language automatically (e.g., via `pyproject.toml` for Python or `package.json` + `tsconfig.json` for TypeScript).
- For hybrid projects, apply rules per sub-directory or module as appropriate.
- Default dependencies (core, non-language-specific): None required universally; add based on needs.
- See language-specific sections for details on managers, virtual environments, and defaults.

## Project Initialization Policy
- Detect project language and apply relevant initialization.
- Create `.env` and `config.yaml` according to Configuration Management policy.
- Create `LICENSE` file according to Licensing Policy.
- Create logging setup according to Logging Policy (e.g., `log.[py/ts]`).
- Create `README.md` according to Project Policy.
- For Python: Create `config.py`.
- For TypeScript: Create `config.ts` and `tsconfig.json`.
- Initialize package manager files (e.g., `pyproject.toml` for Python, `package.json` for TypeScript).

## Documentation Policy
- Use **MkDocs** as default for project-level documentation; goes under docs/ folder at root level.
- For TypeScript projects, integrate TypeDoc for API docs if needed, but default to MkDocs.
- Document language-specific elements accordingly (e.g., Python docstrings vs. JSDoc).

## Logging Policy
- Let the user decide whether logs should be recorded to file/db for different modules.
- Implement and update logging according to project context (e.g., logging for APIs, apps, AI agents differ slightly in their requirements).
- Use language-appropriate libraries (e.g., Python's `logging` module or TypeScript's `winston` or `console`).
- You can refer to SPEC.md at project root for any logging-specific requirements.

## Licensing Policy
- Add LICENSE at repo root.  
- Default: MIT.  
- If specified, generate standard text for license type (Apache-2.0, GPL-3.0, AGPL-3.0, BSD, MPL, LGPL, CC0, Unlicense).  
- Replace `[year]` with current year, `[fullname]` with repo owner/org.  
- If `spec.md`, `SECURITY.md`, or NFRs suggest stricter requirements, propose a restrictive license (e.g., GPL, AGPL, or proprietary) and prompt user.  

## Coding Standards & Design Patterns
- Store DB connection details in `.env`.  
- Namespace env vars with `__` to avoid conflicts (e.g., `SUPABASE__DB_USER`).  
- Add comments and up-to-date docstrings to functions (using language-appropriate formats, e.g., Python docstrings or JSDoc in TypeScript).
- Do not add dependencies on external services without asking first.
- Follow language-specific standards (see below).

## Configuration Management
- **config.yaml:** Store non-secret configuration.  
- **.env:** Store secrets (passwords, tokens, API keys). Use `SERVICE__ITEM` format. NEVER overwrite existing .env env vars unless explicitly instructed.
- **Dynamic expansion:** Use a YAML loader that expands `${VAR}` from env. Leave unresolved vars unchanged.  
- Expose a unified config object via a language-specific file (e.g., `config.py` or `config.ts`).
- Keep `config.yaml`, `.env`.

## Databases, Data Pipelines & Integrations
- Validate table names by checking schemas of connected databases (using `.env` creds + health checks).  
- Generate YAML ingestion contracts for every external ingestion; include in MkDocs.  
- Follow Configuration Management rules for integration settings. Group multiple creds/endpoints clearly under service name.  
- Document integration-specific requirements in both `SPEC.md` and MkDocs.  
- Use language-appropriate libraries for connections (e.g., SQLAlchemy for Python, Prisma/Knex for TypeScript).

## Project Policy
- Never overwrite `AGENTS.md` unless explicitly instructed.
- Create `SPEC.md` at root. Keep it updated with functional + non-functional requirements.  
- In `README.md`, include basic setup instructions (tailored to language, e.g., `poetry install` for Python or `pnpm install` for TypeScript) and cards that demonstrate quality metrics like test pass/fails, CI/CD status, and any other relevant information. Include basic setup instructions and usage examples. Include a brief 2-3 sentences on the project's goal and what problem it solves (e.g., "We made <the tool> to help <the target audience> do <the task> better / faster etc.").
- For hybrid projects, document multi-language setup clearly.

## Python-Specific Policies
- **Package Management and Virtual Environments**: Use **Poetry** exclusively. Default dependencies: python-dotenv, pyyaml, pydantic, mkdocs-material.
- **Coding Standards**: Follow **PEP8**.
- **Project Initialization Additions**: Create `config.py` and `log.py`.
- **Testing**: Use pytest as default; place tests in tests/ folder.
- **gitignore Patterns**: Include .venv, __pycache__, *.pyc, etc.

## TypeScript-Specific Policies
- **Package Management**: Use **pnpm** as default (fallback to npm/yarn if specified). No virtual environments; manage via node_modules and pnpm-lock.yaml.
- **Default Dependencies**: dotenv, js-yaml, zod (equivalents to Python defaults).
- **Coding Standards**: Follow ESLint + Prettier. Use JSDoc for docstrings. Enforce strict types in tsconfig.json (e.g., "strict: true").
- **Build and Compilation**: Use tsconfig.json for options. Build with tsc, vite, or esbuild. Output to /dist.
- **Project Initialization Additions**: Create package.json, tsconfig.json, .eslintrc.json, .prettierrc. For Node.js, use ts-node for dev.
- **Testing**: Use Jest or Vitest as default. Place tests in __tests__ or alongside source (e.g., file.test.ts).
- **Frontend/Backend Distinctions**: If frontend (e.g., React), add bundler policies (vite/webpack). For deployment, consider Vercel/Netlify.
- **gitignore Patterns**: Include node_modules, dist, .env.local, etc.

## Hybrid Projects Policy
- For projects mixing Python and TypeScript (e.g., Python backend + TS frontend), apply generic policies at root.
- Use sub-directories (e.g., /backend for Python, /frontend for TS) with language-specific init in each.
- Share common files like .env, but namespace vars if needed (e.g., PYTHON__VAR vs. TS__VAR).
- Document hybrid setup in README.md and SPEC.md.