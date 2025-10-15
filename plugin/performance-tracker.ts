import type { Plugin } from "@opencode-ai/plugin"
import { mkdir } from "fs/promises"
import { homedir } from "os"
import path from "path"

// In-memory stores
const writers = new Map<string, Bun.FileSink>()
const totalTokens = new Map<string, number>()
const toolStartTimes = new Map<string, number>()
const toolInputs = new Map<string, any>()
const sessionStartTimes = new Map<string, number>()
const sessionAgents = new Map<string, {primary: string, subagent?: string}>()

export const PerformanceTrackerPlugin: Plugin = async ({ client, $, directory }) => {
  // Helper to extract session ID from event
  function extractSessionId(event: any): string {
    if (event.properties.sessionID) return event.properties.sessionID
    if (event.properties.info?.sessionID) return event.properties.info.sessionID
    if (event.properties.info?.id && event.properties.info.id.startsWith("ses_")) return event.properties.info.id
    if (event.properties.part?.sessionID) return event.properties.part.sessionID
    return "unknown"
  }

  // Helper to get short session ID
  function getShortSessionId(sessionId: string): string {
    return sessionId.slice(-6)
  }

  // Helper to get or create writer for session
  async function getWriter(sessionId: string) {
    if (writers.has(sessionId)) return writers.get(sessionId)!
    const logsDir = path.join(homedir(), '.config', 'opencode', 'logs')
    await mkdir(logsDir, { recursive: true })
    const startTime = sessionStartTimes.get(sessionId) || Date.now()
    const shortId = getShortSessionId(sessionId)
    const logPath = path.join(logsDir, `${startTime}-${shortId}.log`)
    const writer = Bun.file(logPath).writer()
    writers.set(sessionId, writer)
    totalTokens.set(sessionId, 0)
    return writer
  }



  return {
    // NEW: Log agent invocations
    "agent.invoked": async ({ agent, mode, sessionID }) => {
      const writer = await getWriter(sessionID)

      // Update session agent tracking
      const current = sessionAgents.get(sessionID) || { primary: '', subagent: undefined }
      if (mode === 'primary') {
        current.primary = agent
      } else if (mode === 'subagent') {
        current.subagent = agent
      }
      sessionAgents.set(sessionID, current)

      const logEntry = {
        type: "agent_invocation",
        session_id: sessionID,
        agent_name: agent,
        agent_mode: mode, // 'primary' or 'subagent'
        timestamp: Date.now(),
      }

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()
    },

    // NEW: Log agent switches
    "agent.switched": async ({ fromAgent, toAgent, sessionID }) => {
      const writer = await getWriter(sessionID)

      const logEntry = {
        type: "agent_switch",
        session_id: sessionID,
        from_agent: fromAgent,
        to_agent: toAgent,
        timestamp: Date.now(),
      }

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()
    },

    // NEW: Track session start time
    "session.started": async ({ sessionID }) => {
      sessionStartTimes.set(sessionID, Date.now())

      const writer = await getWriter(sessionID)
      const logEntry = {
        type: "session_start",
        session_id: sessionID,
        timestamp: Date.now(),
      }

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()
    },

    // Log per message
    "chat.message": async (input, { message, parts }) => {
      const sessionId = message.sessionID
      const writer = await getWriter(sessionId)

      // Use actual token counts from message
      const tokens = message.tokens
        ? {
            input: message.tokens.input || 0,
            output: message.tokens.output || 0,
            reasoning: message.tokens.reasoning || 0,
            cache: {
              read: message.tokens.cache?.read || 0,
              write: message.tokens.cache?.write || 0,
            },
          }
        : {
            input: 0,
            output: 0,
            reasoning: 0,
            cache: { read: 0, write: 0 },
          }

      // Count thinking loops (reasoning parts)
      let thinkingLoops = 0
      parts.forEach((part) => {
        if (part.type === "reasoning") thinkingLoops++
      })

      // Latency: for assistant, time from created to completed
      const latency = message.time?.completed ? message.time.completed - message.time.created : 0

      const tokenSum = tokens.input + tokens.output + tokens.reasoning + tokens.cache.read + tokens.cache.write
      totalTokens.set(sessionId, (totalTokens.get(sessionId) || 0) + tokenSum)

      // Validation: warn if no tokens captured for assistant messages
      if (message.role === "assistant" && tokenSum === 0) {
        console.warn(`PerformanceTracker: No tokens logged for assistant message ${message.id}`)
      }

      const logEntry = {
        type: "message",
        session_id: sessionId,
        id: message.id,
        role: message.role,
        tokens,
        latency,
        thinking_loops: thinkingLoops,
        content_length: message.content?.length || 0,
        timestamp: Date.now(),
      }

      // Additional logging for assistant messages with token details
      if (message.role === "assistant") {
        const assistantLog = {
          type: "assistant_tokens",
          session_id: sessionId,
          message_id: message.id,
          input_tokens: tokens.input,
          output_tokens: tokens.output,
          reasoning_tokens: tokens.reasoning,
          cache_read: tokens.cache.read,
          cache_write: tokens.cache.write,
          total: tokenSum,
          latency,
          thinking_loops: thinkingLoops,
          timestamp: Date.now(),
        }
        writer.write(JSON.stringify(assistantLog) + "\n")
        await writer.flush()
      }

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()
    },

    // Track tool start
    "tool.execute.before": async ({ tool, sessionID, callID }, { args }) => {
      toolStartTimes.set(callID, Date.now())
      toolInputs.set(callID, args)
    },

    // Log tool executions
    "tool.execute.after": async (input, output) => {
      const { tool, sessionID, callID } = input
      const writer = writers.get(sessionID)
      if (!writer) return

      const startTime = toolStartTimes.get(callID)
      const executionTime = startTime ? Date.now() - startTime : 0
      toolStartTimes.delete(callID)

      const logEntry = {
        type: "tool_execution",
        session_id: sessionID,
        name: tool,
        call_id: callID,
        execution_time: executionTime,
        input: toolInputs.get(callID) || {},
        output: output.output,
        timestamp: Date.now(),
      }
      toolInputs.delete(callID)

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()
    },

    // Log selective events (exclude message.part.updated to avoid duplication)
    event: async ({ event }) => {
      // Skip logging message.part.updated as it duplicates response stream data
      if (event.type === "message.part.updated") return

      // Extract session ID from event
      const sessionId = extractSessionId(event)
      const writer = await getWriter(sessionId)

      const logEntry = {
        type: "event",
        event_type: event.type,
        properties: event.properties,
        timestamp: Date.now(),
      }

      writer.write(JSON.stringify(logEntry) + "\n")
      await writer.flush()

      // On session end, finalize
      if (event.type === "session.idle") {
        const sessionId = event.properties.sessionID
        const writer = writers.get(sessionId)
        if (!writer) {
          console.warn(`PerformanceTracker: No writer found for session ${sessionId} on idle event`)
          return
        }

        // Fetch config
        const config = await client.Config.get()
        const agents = sessionAgents.get(sessionId) || { primary: '', subagent: undefined }

        const endLogEntry = {
          type: "session_end",
          session_id: sessionId,
          total_tokens: totalTokens.get(sessionId) || 0,
          primary_agent: agents.primary,
          subagent: agents.subagent,
          config,
          timestamp: Date.now(),
        }

        writer.write(JSON.stringify(endLogEntry) + "\n")
        await writer.flush()
        writer.end()

        writers.delete(sessionId)
        totalTokens.delete(sessionId)
        sessionStartTimes.delete(sessionId)
        sessionAgents.delete(sessionId)
      }
    },
  }
}
