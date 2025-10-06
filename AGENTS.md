# AGENT.md

## Temporary Files Policy
**ALL temporary, ad-hoc, or sample data MUST go in the `.temp/` folder:**

- **Location**: `.temp/` folder at project root
- **Git Status**: Automatically ignored via `.gitignore`
- **Purpose**: Keep repository clean of non-essential files

**Files that BELONG in `.temp/`:**
- Database schema dumps (`sample_schema_output.txt`)
- Test data exports (`test_export.csv`)
- Debug outputs (`debug_results.json`)
- Exploratory data analysis results
- Any file created for investigation that shouldn't be committed

**Files that do NOT belong in `.temp/`:**
- Configuration files
- Source code
- Documentation
- Production data

## 🛠️ Utilities
Place helper functions, scripts, or tools for repetitive development tasks in a `/utils` folder. These are not part of the application runtime but speed up developer workflows.

**Examples:**
- **Database helpers** → `utils/db_inspector.py` for schema exploration
- **Health checks** → `utils/health_check.py` for service verification
- **Build scripts** → Docker image builders, artifact packagers
- **Code quality tools** → Linting, formatting, test runners
- **Data sampling scripts** → Preview external data sources

## GitHub & Git
- Use feature branches from `main` (default). If the user requests, migrate to new strategy.  
- Commit with [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).  
- Work only on `dev` or feature branches. Confirm with user if multiple feature branches are active.  
- Always use Git. If missing, init repo with `.gitignore` (Python if Python project), README, and LICENSE.  
- Use **GitHub CLI (`gh`)** if available to publish branches, open pull requests, and manage repo interactions. Fall back to the GitHub web UI if CLI is unavailable.  
- when generating the body of the pull request description, use a temporary markdown file and the --body-file argument, delete the markdown file when finished.

## Package Management & Artifacts
- Use **Poetry** in all Python projects.  
- Add **python-dotenv** as a default dependency.  
- Create `.env` with placeholder values.  
- Use **MkDocs**; keep docs updated per branch and verify before merging.  
- Create `config.yaml` for non-secret config. Secrets go in `.env`. Promote config to env only if user specifies.  
- Create `config.py` to parse `config.yaml` + `.env`, expose a unified config object, obfuscate secrets in logs.  
- Create `log.py` with a colorful custom logger.  

## Licensing
- Add LICENSE at repo root.  
- Default: MIT.  
- If specified, generate standard text for license type (Apache-2.0, GPL-3.0, AGPL-3.0, BSD, MPL, LGPL, CC0, Unlicense).  
- Replace `[year]` with current year, `[fullname]` with repo owner/org.  
- If `spec.md`, `SECURITY.md`, or NFRs suggest stricter requirements, propose a restrictive license (e.g., GPL, AGPL, or proprietary) and prompt user.  

## Coding Standards
- Store DB connection details in `.env`.  
- Namespace env vars with `__` to avoid conflicts (e.g., `SUPABASE__DB_USER`).  
- Follow **PEP8**.  
- Add comments and up-to-date docstrings to functions. 
- Do not add dependencies on external services without asking first

## Configuration Management
- **config.yaml:** store non-secret configuration.  
- **.env:** store secrets (passwords, tokens, API keys). Use `SERVICE__ITEM` format. NEVER overwrite existing .env env vars unless explicitly instructed.
- **Dynamic expansion:** use a YAML loader that expands `${VAR}` from env. Leave unresolved vars unchanged.  
- **config.py:** parse both `config.yaml` and `.env`; expose a unified `config` object; obfuscate secrets when logged.  
- Keep `config.yaml`, `.env`, and MkDocs consistent. 
- Never overwrite AGENTS.md unless explicitly instructed.

## Databasese, Data Pipelines & Integrations
- Validate table names by checking schemas of connected databases (using `.env` creds + health checks).  
- Generate YAML ingestion contracts for every external ingestion; include in MkDocs.  
- Follow Configuration Management rules for integration settings. Group multiple creds/endpoints clearly under service name.  
- Document integration-specific requirements in both `SPEC.md` and MkDocs.  

## Project Specifications
- Create `SPEC.md` at root. Keep it updated with functional + non-functional requirements.  
- In `README.md`, include background, goals, and challenges.  
- Create `JOURNAL.md` at root to record pivots, architecture decisions, major challenges, and other notes of record. Update this file as the project evolves.  
