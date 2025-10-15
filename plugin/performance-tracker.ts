import type { Plugin } from "@opencode-ai/plugin"
import { z } from "zod"

// Schema for performance log
const PerformanceLogSchema = z.object({
  sessionId: z.string(),
  timestamp: z.number(),
  messages: z.array(
    z.object({
      id: z.string(),
      role: z.string(),
      tokens: z.object({
        input: z.number(),
        output: z.number(),
        reasoning: z.number(),
      }),
      latency: z.number(), // ms
      thinkingLoops: z.number(),
    }),
  ),
  tools: z.array(
    z.object({
      name: z.string(),
      callId: z.string(),
      executionTime: z.number(), // ms
      input: z.any(),
      output: z.any(),
    }),
  ),
  config: z.any(), // Full config snapshot
})

type PerformanceLog = z.infer<typeof PerformanceLogSchema>

// In-memory store (in production, use persistent storage)
const logs = new Map<string, PerformanceLog>()
const toolStartTimes = new Map<string, number>()

export const PerformanceTrackerPlugin: Plugin = async ({ client, $, directory }) => {
  return {
    // Log per message
    "chat.message": async ({ message, parts }) => {
      const sessionId = message.sessionID
      if (!logs.has(sessionId)) {
        logs.set(sessionId, {
          sessionId,
          timestamp: Date.now(),
          messages: [],
          tools: [],
          config: null,
        })
      }
      const log = logs.get(sessionId)!

      // Use actual token counts from message
      const tokens = message.tokens || { input: 0, output: 0, reasoning: 0 }

      // Count thinking loops (reasoning parts)
      let thinkingLoops = 0
      parts.forEach((part) => {
        if (part.type === "reasoning") thinkingLoops++
      })

      // Latency: for assistant, time from created to completed
      const latency = message.time?.completed ? message.time.completed - message.time.created : 0

      log.messages.push({
        id: message.id,
        role: message.role,
        tokens,
        latency,
        thinkingLoops,
      })
    },

    // Track tool start
    "tool.execute.before": async ({ tool, sessionID, callID }, { args }) => {
      toolStartTimes.set(callID, Date.now())
    },

    // Log tool executions
    "tool.execute.after": async ({ tool, sessionID, callID, output }) => {
      const log = logs.get(sessionID)
      if (!log) return

      const startTime = toolStartTimes.get(callID)
      const executionTime = startTime ? Date.now() - startTime : 0
      toolStartTimes.delete(callID)

      log.tools.push({
        name: tool,
        callId: callID,
        executionTime,
        input: {}, // Could store from before hook if needed
        output,
      })
    },

    // On session end, zip and save
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const sessionId = event.sessionId // Assume event has sessionId
        const log = logs.get(sessionId)
        if (!log) return

        // Fetch config
        log.config = await client.Config.get()

        // Zip and save
        const logData = JSON.stringify(log)
        const zipPath = `${directory}/.opencode/logs/${sessionId}-performance.zip`
        await $`mkdir -p ${directory}/.opencode/logs`
        await Bun.write(zipPath, logData) // Simplified; use actual zipping

        logs.delete(sessionId)
      }
    },
  }
}
