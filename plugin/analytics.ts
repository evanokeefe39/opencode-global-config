import fs from "fs/promises"
import path from "path"
import { homedir } from "os"

interface LogEntry {
  type: string
  timestamp: number
  session_id: string
  [key: string]: any
}

export class AnalyticsEngine {
  private logsDir: string
  private entries: LogEntry[] = []

  constructor() {
    this.logsDir = path.join(homedir(), '.config', 'opencode', 'logs')
  }

  async loadLogs(): Promise<void> {
    const logFiles = await fs.readdir(this.logsDir)
    // Updated pattern to match new filename format: timestamp-6chars.log
    const performanceLogs = logFiles.filter(f => /^\d+-[a-f0-9]{6}\.log$/.test(f))

    for (const logFile of performanceLogs) {
      const filePath = path.join(this.logsDir, logFile)
      const content = await fs.readFile(filePath, 'utf-8')
      const lines = content.trim().split('\n')

      for (const line of lines) {
        try {
          const entry: LogEntry = JSON.parse(line)
          this.entries.push(entry)
        } catch (e) {
          // Skip malformed lines
        }
      }
    }

    // Sort by timestamp
    this.entries.sort((a, b) => a.timestamp - b.timestamp)
  }

  private filterByTimeRange(timeRange: string): LogEntry[] {
    const now = Date.now()
    let cutoff = 0

    switch (timeRange) {
      case "last_24h": cutoff = now - 24 * 60 * 60 * 1000; break
      case "last_7d": cutoff = now - 7 * 24 * 60 * 60 * 1000; break
      case "last_30d": cutoff = now - 30 * 24 * 60 * 60 * 1000; break
      default: return this.entries
    }

    return this.entries.filter(e => e.timestamp >= cutoff)
  }

  generateSummary(timeRange: string = "all", format: string = "json") {
    const entries = this.filterByTimeRange(timeRange)

    const summary = {
      total_sessions: new Set(entries.filter(e => e.type === 'session_end').map(e => e.session_id)).size,
      total_messages: entries.filter(e => e.type === 'message' && e.role === 'assistant').length,
      total_tokens: entries.filter(e => e.type === 'session_end').reduce((sum, e) => sum + (e.total_tokens || 0), 0),
      avg_response_time: this.calculateAverageResponseTime(entries),
      total_tool_executions: entries.filter(e => e.type === 'tool_execution').length,
      time_range: timeRange,
      generated_at: Date.now()
    }

    return format === "json" ? summary : this.formatAsText(summary)
  }

  analyzeTokensOverTime(timeRange: string = "all", format: string = "json") {
    const entries = this.filterByTimeRange(timeRange)
    const tokenEntries = entries.filter(e => e.type === 'assistant_tokens')

    const timeSeries = tokenEntries.map(e => ({
      timestamp: e.timestamp,
      total_tokens: e.total,
      session_id: e.session_id
    }))

    if (format === "chart") {
      return this.generateAsciiChart(timeSeries, 'timestamp', 'total_tokens', 'Token Usage Over Time')
    }

    return { time_series: timeSeries }
  }

  analyzeResponseTimes(timeRange: string = "all", format: string = "json") {
    const entries = this.filterByTimeRange(timeRange)
    const responseEntries = entries.filter(e => e.type === 'message' && e.role === 'assistant' && e.latency > 0)

    const timeSeries = responseEntries.map(e => ({
      timestamp: e.timestamp,
      latency: e.latency,
      session_id: e.session_id
    }))

    if (format === "chart") {
      return this.generateAsciiChart(timeSeries, 'timestamp', 'latency', 'Response Times Over Time')
    }

    return {
      time_series: timeSeries,
      average_latency: timeSeries.reduce((sum, e) => sum + e.latency, 0) / timeSeries.length
    }
  }

  analyzeToolPerformance(timeRange: string = "all", format: string = "json") {
    const entries = this.filterByTimeRange(timeRange)
    const toolEntries = entries.filter(e => e.type === 'tool_execution')

    const toolStats = toolEntries.reduce((acc, e) => {
      const name = e.name
      if (!acc[name]) {
        acc[name] = { count: 0, total_time: 0, avg_time: 0 }
      }
      acc[name].count++
      acc[name].total_time += e.execution_time
      acc[name].avg_time = acc[name].total_time / acc[name].count
      return acc
    }, {} as Record<string, any>)

    return { tool_performance: toolStats }
  }

  // NEW: Agent usage analytics
  analyzeAgentUsage(timeRange: string = "all", format: string = "json") {
    const entries = this.filterByTimeRange(timeRange)

    const agentStats = {
      primary_agents: {} as Record<string, number>,
      subagents: {} as Record<string, number>,
      switches: [] as any[]
    }

    entries.forEach(entry => {
      if (entry.type === 'agent_invocation') {
        const target = entry.agent_mode === 'primary' ? 'primary_agents' : 'subagents'
        agentStats[target][entry.agent_name] = (agentStats[target][entry.agent_name] || 0) + 1
      } else if (entry.type === 'agent_switch') {
        agentStats.switches.push({
          timestamp: entry.timestamp,
          from: entry.from_agent,
          to: entry.to_agent,
          session_id: entry.session_id
        })
      }
    })

    return agentStats
  }

  private calculateAverageResponseTime(entries: LogEntry[]): number {
    const latencies = entries
      .filter(e => e.type === 'message' && e.role === 'assistant' && e.latency > 0)
      .map(e => e.latency)

    return latencies.length > 0 ? latencies.reduce((a, b) => a + b) / latencies.length : 0
  }

  private formatAsText(summary: any): string {
    return `
Performance Analytics Summary
=============================
Time Range: ${summary.time_range}
Generated: ${new Date(summary.generated_at).toISOString()}

Sessions: ${summary.total_sessions}
Messages: ${summary.total_messages}
Total Tokens: ${summary.total_tokens.toLocaleString()}
Average Response Time: ${summary.avg_response_time.toFixed(1)}ms
Tool Executions: ${summary.total_tool_executions}
    `.trim()
  }

  private generateAsciiChart(data: any[], xKey: string, yKey: string, title: string): string {
    if (data.length === 0) return "No data available for chart"

    // Simple ASCII bar chart (could be enhanced with a proper charting library)
    const maxY = Math.max(...data.map(d => d[yKey]))
    const chartWidth = 50

    let chart = `${title}\n${'='.repeat(title.length)}\n`

    data.forEach(d => {
      const barLength = Math.round((d[yKey] / maxY) * chartWidth)
      const bar = '█'.repeat(barLength)
      const time = new Date(d[xKey]).toLocaleTimeString()
      chart += `${time}: ${bar} ${d[yKey]}\n`
    })

    return chart
  }
}