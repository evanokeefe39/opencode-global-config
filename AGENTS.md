# Global Agent Orchestration Rules

## Agent Hierarchy

### Primary Agents (Orchestrators)
These agents have broad capabilities and write files directly:
- `@plan` / `@general`: High-level planning and simple code tasks
- `@build`: Full code implementation and file writing
- Your custom primary agents: Project-specific orchestration

### Subagents (Specialists)
These agents are **invoked by primary agents** for specific, constrained tasks:
- `@version-control`: Git/GitHub operations only
- `@docs`: Documentation only
- `@deploy`: Deployments only
- `@debug`: Investigation only

## Delegation Pattern

**Primary agents should DELEGATE to subagents for:**

1. **Git Operations** → `@version-control`
   - Never run `git commit`, `git push`, `gh pr create` directly
   - Always delegate: "version-control create branch for auth"
   - Reason: Ensures consistent branch naming, commit format, PR process

2. **Documentation** → `@docs`
   - After code changes, always delegate: "docs update README with new API"
   - Reason: Maintains doc quality and consistency

3. **Deployments** → `@deploy`
   - Never run deploy commands directly: "deploy to staging"
   - Reason: Enforces CI checks, approval gates, and safety protocols

4. **Error Investigation** → `@debug`
   - On any failure: "debug analyze build failure"
   - Reason: Gets systematic RCA instead of guesswork

## What Primary Agents CAN Do Directly

**File Operations:**
- ✅ Write code files (`@build` writes source code)
- ✅ Edit configuration files
- ✅ Create new project files
- ✅ Modify existing implementations

**Planning & Analysis:**
- ✅ Create multi-step plans
- ✅ Analyze requirements
- ✅ Design architectures
- ✅ Review code changes

**Simple Git (for speed):**
- ✅ `git status` (read-only, no delegation needed)
- ❌ `git commit`, `git push` (must delegate to `@version-control`)

## Quality Gates Flow

User Request → Primary Agent (@build) → 
  1. version-control create branch
  2. [write code files directly]
  3. docs update README
  4. debug verify no errors
  5. deploy to staging
  6. version-control merge PR

## Emergency Overrides

In rare cases, primary agents may bypass delegation ONLY when:
- Task is **trivial** (< 5 lines of docs)
- **Speed** is critical (hotfix)
- Subagent is **unavailable** (permission issue)

In these cases, add comment: `# OVERRIDE: Direct execution due to [reason]`