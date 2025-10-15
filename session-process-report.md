# OpenCode User Session Process Flow: Detailed Report

## Overview

This report provides a comprehensive breakdown of the process flow from a user sending a message in the OpenCode TUI to receiving the AI response. It covers input handling, message processing, session orchestration, planning logic, LLM interactions, and response streaming. The architecture incorporates think-plan-do and ReAct (Reason + Act) patterns through agent modes and iterative loops.

## 1. User Input Capture in TUI

**Primary File**: `packages/tui/internal/tui/tui.go`

### Process Steps:

- User types input in the chat editor component (`chat.EditorComponent`).
- Input is handled in the `Update` method (line 99), checking for key presses.
- On submit (e.g., Enter key), `editor.Submit()` is called (line 806), which creates an `app.SendPrompt` message containing:
  - Text content
  - Attachments (files, symbols, agents)
- The message is routed via `util.CmdHandler(app.SendPrompt{...})` (line 402).
- <span style="color: green;">**[Config Applied]**</span>: Agent selection influenced by `initialAgent` from command-line flags or config (line 154).
- If in child session, switches to parent before sending (lines 394-410).

### Orchestration/Planning:

- Checks for active modals, completions, or bash mode.
- Debounces interrupt/exit keys for session control.

### Self-Reflection:

- None at TUI level; input is forwarded to app layer.

## 2. Message Processing in App Layer

**Primary File**: `packages/opencode/src/app/app.go`

### Process Steps:

- `SendPrompt` method (line 783) receives the prompt.
- Ensures session exists: If `a.Session.ID` is empty, calls `CreateSession` (line 785) to initialize via `Client.Session.New`.
- <span style="color: green;">**[Config Applied]**</span>: Agent retrieved from `a.Agent()` (line 805), which uses config-loaded agent (from `agent.ts`).
- Converts `Prompt` to `Message` struct (line 794):
  - Creates `UserMessage` with ID, session ID, role, and timestamp.
  - Processes attachments into parts (text, file, agent).
- Appends to `a.Messages` array (line 797).
- Calls `Client.Session.Prompt` API (line 800) with parameters:
  - Model/provider details (from config-selected model)
  - Agent name (config-defined)
  - Message ID
  - Serialized parts

### Orchestration/Planning:

- Session management and API bridging.
- No explicit planning; delegates to session layer.

### Self-Reflection:

- Relies on session-level iterative reasoning.

### LLM Call:

- Indirect via HTTP POST to `/session/{id}/prompt` endpoint.

## 3. Session Prompt Handling and Planning

**Primary File**: `packages/opencode/src/session/prompt.ts`

### Process Steps:

- Main processing loop: `while (true)` (line 211) for iterative conversation turns.
- Fetches messages via `getMessages` (line 212), including history.
- <span style="color: green;">**[Config Applied]**</span>: Agent passed to `insertReminders` (line 218), using config-defined agent with mode (primary/subagent).
- Inserts agent-specific reminders via `insertReminders` (line 218):
  - **Detailed Explanation**: `insertReminders` injects synthetic text parts into the last user message to enforce think-plan-do workflows. It does **not** extract from user config; uses hardcoded logic:
    - For "plan" agent: Appends `PROMPT_PLAN` (from `plan.txt`), enforcing read-only planning mode.
    - For "build" agent after a prior "plan" message: Appends `BUILD_SWITCH` (from `build-switch.txt`), signaling mode switch to execution.
  - These are invisible to users but guide LLM behavior for safety and structure.
- <span style="color: green;">**[Config Applied]**</span>: System prompts assembled from `SystemPrompt.provider()` and `SystemPrompt.custom()` (line 283), including AGENTS.md rules.
- Creates processor and calls `processor.next()` (line 229).
- <span style="color: green;">**[Config Applied]**</span>: Tools loaded from `ToolRegistry.tools()` (line 436), filtered by config-defined agent tools.
- Invokes `streamText` (line 233) for LLM interaction.

### Orchestration/Planning:

- **Plan Mode**: "plan" agent operates in read-only (edit: "deny", bash: "ask"). Forces planning phase.
- **Build Mode**: Switches via build-switch prompt, enabling execution.
- Uses `todowrite`/`todoread` tools for task breakdown (referenced in prompts like `beast.txt`).
- Iterative loop allows multi-turn planning and execution.

### Self-Reflection:

- System prompts instruct: "think through every step," "plan extensively before each function call," "reflect extensively on outcomes" (e.g., `beast.txt` lines 24-26, `copilot-gpt-5.txt` lines 11-12).
- Model reflects via reasoning parts in stream.

### LLM Call:

- Direct via `streamText` with:
  - System prompts (provider-specific from `system.ts`)
  - Message history
  - Active tools
  - Streaming enabled

## 4. LLM Interaction and Tool Execution

**Primary File**: `packages/opencode/src/session/prompt.ts` (continued)

### Process Steps:

- `processor.process(stream)` (line 884) handles streaming response.
- `for await` loop (line 891) processes stream events:
  - `reasoning-start/delta/end`: Accumulates reasoning text (lines 900-938).
  - `tool-call`: Executes tools via registered functions (line 962).
  - <span style="color: green;">**[Config Applied]**</span>: Tool execution respects agent permissions from config (e.g., edit/bash restrictions).
  - `tool-result/error`: Updates parts with outcomes (lines 981-1023).
  - `text-start/delta/end`: Builds text response (lines 1073-1100).
  - `finish-step`: Records usage and patches (lines 1040-1070).
- Tool calls are asynchronous; results feed back into next iteration.

### Orchestration/Planning:

- ReAct Pattern: Model reasons → Acts via tools → Reflects → Continues loop.
- Planning enforced via agent modes and prompt instructions.

### Self-Reflection:

- Model instructed to reflect on tool outcomes and adjust plans.

### LLM Call:

- Streaming via `streamText`, with transforms for provider compatibility (`ProviderTransform`).

## 5. Response Streaming and UI Updates

**Primary File**: `packages/tui/internal/tui/tui.go`

### Process Steps:

- SSE events from server update `app.Messages` (e.g., `EventMessagePartUpdated` line 480).
- UI re-renders via `messages.Update` and `chat.MessagesComponent`.
- Real-time display of reasoning, tool outputs, and text.

### Orchestration/Planning:

- Passive; no additional logic.

### Self-Reflection:

- Displays model's reflective output.

## Key Files Summary

- **TUI**: `packages/tui/internal/tui/tui.go` - Input/UI.
- **App**: `packages/opencode/src/app/app.go` - Session/API bridge.
- **Session/Planning**: `packages/opencode/src/session/prompt.ts` - Core loop, agents, LLM.
- **Prompts**: `packages/opencode/src/session/prompt/*.txt` - Self-reflection instructions.
- **Agents**: `packages/opencode/src/agent/agent.ts` - Mode definitions (plan/build).
- **System**: `packages/opencode/src/session/system.ts` - Prompt assembly.

## 6. Incorporation of Global and Project Config

**Primary Files**: `packages/opencode/src/config/config.ts`, `packages/opencode/src/agent/agent.ts`, `packages/opencode/src/session/system.ts`

### Process Steps:

- <span style="color: green;">**[Config Applied]**</span>: **Config Loading** (`config.ts`): Hierarchical loading (line 24):
  - Global config from `Global.Path.config`.
  - Project config from `opencode.jsonc`/`opencode.json` in project directory (via `Filesystem.findUp`).
  - Overrides from flags or env vars.
  - Merged with auth and well-known configs.
- <span style="color: green;">**[Config Applied]**</span>: **Agent Definitions** (`agent.ts`): Agents loaded from config (line 40):
  - Built-in agents: "general" (subagent), "build" (primary), "plan" (primary).
  - Custom agents from `cfg.agent` with modes: "subagent", "primary", "all".
  - Permissions, tools, models overridden from config.
- <span style="color: green;">**[Config Applied]**</span>: **AGENTS.md Integration** (`system.ts`): `custom()` function (line 68):
  - Loads AGENTS.md from project root or global (`~/.opencode/AGENTS.md`).
  - Also loads other rule files (CLAUDE.md) and config.instructions.
  - Content appended to system prompts for planning/thinking logic.

### Orchestration/Planning:

- Agent selection in TUI/App: Based on initialAgent, state, or defaults (e.g., "build" primary).
- Mode enforcement: Subagents delegate, primaries handle full flow.
- Planning logic customized via AGENTS.md rules in prompts.

### Self-Reflection:

- AGENTS.md provides project-specific guidelines for thinking/planning.

## 7. Agent Memory

**Primary Files**: `packages/opencode/src/session/index.ts`, `packages/opencode/src/storage/storage.ts`, `packages/opencode/src/session/compaction.ts`

### Memory Scope:

- **Session-Scoped Only**: Agent memory (messages, parts, todos, usage) is stored per session using `Storage` (key-value store). It does not span across sessions; each session starts fresh.
- **What is Stored**: Conversation history, reasoning parts, tool calls/results, and metadata persist within a session for iterative reasoning.
- **Compaction**: Sessions can be summarized (`compaction.ts`) for efficiency, but summaries remain session-specific.
- **No Cross-Session Memory**: Agents reset per session; no global or persistent agent state across conversations.

## 8. System Prompts

**Primary Files**: `packages/opencode/src/session/system.ts`, `packages/opencode/src/session/prompt/*.txt`

### Overview:

System prompts are loaded via `SystemPrompt.provider()` based on model ID (e.g., Anthropic, OpenAI, Gemini) and appended to LLM requests for consistent behavior. They enforce rules, workflows, and safety.

### Prompt Details:

- **anthropic.txt**: General Anthropic prompt; emphasizes concise responses, tool usage, and defensive security.
- **anthropic_spoof.txt**: Spoofed Anthropic prompt for compatibility; minimal content.
- **anthropic-20250930.txt**: Security-focused; restricts malicious code assistance.
- **beast.txt**: Aggressive OpenAI prompt; mandates iteration, testing, and extensive planning/reflection.
- **codex.txt**: OpenCode-specific prompt; focuses on planning, tool calls, and user communication.
- **copilot-gpt-5.txt**: GitHub Copilot prompt; emphasizes research, iteration, and boundary case handling.
- **gemini.txt**: Gemini prompt; prioritizes UI implementation, placeholders, and proactive asset creation.
- **qwen.txt**: Qwen prompt; includes security rules, style guidelines, and tool policies.
- **plan.txt**: System reminder for "plan" agent mode; enforces read-only planning phase.
- **build-switch.txt**: Switches from plan to build mode; enables execution permissions.
- **initialize.txt**: Instructions for creating AGENTS.md with build/lint/test commands and style guidelines.
- **summarize.txt**: Prompt for conversation summarization; focuses on key actions and next steps.
- **title.txt**: Prompt for generating concise thread titles from user messages.

### Usage in Sessions:

- Selected in `SystemPrompt.provider()` (system.ts) based on model ID.
- Combined with custom rules from AGENTS.md via `SystemPrompt.custom()`.
- Sent with each LLM call in `prompt.ts` to guide reasoning, tool use, and responses.

## 9. Plugin Integration

**Primary Files**: `packages/plugin/src/index.ts`, `packages/opencode/src/session/prompt.ts`

### Overview:

Users can create custom plugins to extend functionality, including logging metrics like token consumption and response times. Plugins are loaded and hooks are called during session processing.

### Plugin Hooks:

- **event**: Triggered on system events (e.g., session end); can log aggregated metrics.
- **chat.message**: Called on each new message; ideal for per-response logging (tokens, time).
- **chat.params**: Modify LLM parameters before calls.
- **tool.execute.before/after**: Hook before/after tool execution; can measure response times.
- **permission.ask**: Handle permission requests.
- **config/auth/tool**: Extend config, auth methods, or add custom tools.

### Integration in Sessions:

- Plugins are imported in `prompt.ts` and hooks are invoked at relevant points (e.g., after message processing or tool calls).
- Users can implement logging in hooks, e.g., `chat.message` to record token usage from `assistantMsg.tokens` and timestamps.
- Session end logging possible via `event` hook on session deletion or completion events.

### Example Usage:

Users can write plugins to log metrics to external systems, enabling custom analytics on token consumption, response times, etc., per response or session.

## Architecture Patterns

- **Think-Plan-Do**: Plan agent for planning, build for execution, with mode switches.
- **ReAct**: Iterative reason-act cycles in the while loop.
- **Chain-of-Thought**: Reasoning parts and prompt instructions enable step-by-step thinking.
- **Config-Driven**: Agents and rules loaded from global/project config for customization.
- **Session-Isolated Memory**: Ensures privacy and prevents unbounded context growth.

This flow ensures robust, iterative AI interactions with safety checks and planning enforcement.
