# MCP Integration Guide

## Overview
OpenCode integrates MCP (Model Context Protocol) servers to enhance capabilities beyond built-in tools. This doc covers context7 for advanced file/context operations and GitHub MCP for repository automation.

## Context7 MCP
- **Purpose**: Provides enhanced file searching, context retrieval, and analysis.
- **Usage**: Replaces basic grep/file reads with intelligent context-aware searches.
- **Example**: Instead of `grep "function" *.js`, use context7 MCP to search with semantic understanding.

## GitHub MCP
- **Purpose**: Handles GitHub operations like PR management, issue tracking, and repo stats.
- **Usage**: Bypasses GH CLI for direct API interactions.
- **Example**: Create PRs via MCP tools instead of `gh pr create`, with automatic template application.

## Configuration
Configure in `opencode.json` under `mcp` (see https://opencode.ai/docs/mcp-servers/).

## Best Practices
- Enable per-agent to avoid global overhead.
- Use for complex queries; fallback to CLI for simple ops.
- Monitor for rate limits and auth issues.