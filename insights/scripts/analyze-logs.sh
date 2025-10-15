#!/bin/bash
set -e

LOGS_DIR="${HOME}/.config/opencode/logs"
INSIGHTS_DIR="insights"
DATA_DIR="${INSIGHTS_DIR}/data"
CHARTS_DIR="${INSIGHTS_DIR}/charts"

# Create directories
mkdir -p "$DATA_DIR" "$CHARTS_DIR"

echo "Analyzing performance logs..."

# Function to extract metrics from logs
extract_metrics() {
    local log_file="$1"

    # Extract token usage (assistant_tokens type)
    jq -r 'select(.type == "assistant_tokens") | [.timestamp, .total, .session_id] | @csv' "$log_file" >> "${DATA_DIR}/token-usage-raw.csv"

    # Extract response latency (message type, assistant role)
    jq -r 'select(.type == "message" and .role == "assistant" and .latency > 0) | [.timestamp, .latency, .session_id] | @csv' "$log_file" >> "${DATA_DIR}/latency-raw.csv"

    # Extract tool executions
    jq -r 'select(.type == "tool_execution") | [.timestamp, .name, .execution_time, .session_id] | @csv' "$log_file" >> "${DATA_DIR}/tools-raw.csv"

    # Extract session ends for totals
    jq -r 'select(.type == "session_end") | [.timestamp, .total_tokens, .session_id] | @csv' "$log_file" >> "${DATA_DIR}/sessions-raw.csv"
}

# Process all log files
echo "timestamp,total_tokens,session_id" > "${DATA_DIR}/token-usage-raw.csv"
echo "timestamp,latency,session_id" > "${DATA_DIR}/latency-raw.csv"
echo "timestamp,tool_name,execution_time,session_id" > "${DATA_DIR}/tools-raw.csv"
echo "timestamp,total_tokens,session_id" > "${DATA_DIR}/sessions-raw.csv"

for log_file in "$LOGS_DIR"/*.log; do
    if [[ -f "$log_file" ]]; then
        echo "Processing $log_file"
        extract_metrics "$log_file"
    fi
done

# Aggregate data by day
echo "Aggregating data..."

# Token usage by day
tail -n +2 "${DATA_DIR}/token-usage-raw.csv" | \
awk -F',' '
    function get_date(ts) {
        cmd = "date -d @" int(ts/1000) " +%Y-%m-%d"
        cmd | getline date_str
        close(cmd)
        return date_str
    }
    {
        date = get_date($1)
        tokens[date] += $2
        count[date]++
    }
    END {
        print "date,total_tokens,daily_messages"
        for (d in tokens) {
            print d "," tokens[d] "," count[d]
        }
    }
' | sort > "${DATA_DIR}/token-usage-daily.csv"

# Response latency by day
tail -n +2 "${DATA_DIR}/latency-raw.csv" | \
awk -F',' '
    function get_date(ts) {
        cmd = "date -d @" int(ts/1000) " +%Y-%m-%d"
        cmd | getline date_str
        close(cmd)
        return date_str
    }
    {
        date = get_date($1)
        sum[date] += $2
        count[date]++
    }
    END {
        print "date,avg_latency_ms,message_count"
        for (d in sum) {
            avg = count[d] > 0 ? sum[d]/count[d] : 0
            print d "," avg "," count[d]
        }
    }
' | sort > "${DATA_DIR}/response-latency-daily.csv"

# Tool usage by day
tail -n +2 "${DATA_DIR}/tools-raw.csv" | \
awk -F',' '
    function get_date(ts) {
        cmd = "date -d @" int(ts/1000) " +%Y-%m-%d"
        cmd | getline date_str
        close(cmd)
        return date_str
    }
    {
        date = get_date($1)
        tools[date][$2]++
        total[date]++
    }
    END {
        print "date,tool_name,invocations,total_tools"
        for (d in tools) {
            for (t in tools[d]) {
                print d "," t "," tools[d][t] "," total[d]
            }
        }
    }
' | sort > "${DATA_DIR}/tool-invocations-daily.csv"

# Cost estimation (simplified - adjust pricing as needed)
echo "Estimating costs..."
tail -n +2 "${DATA_DIR}/token-usage-daily.csv" | \
awk -F',' '
    # Pricing: $0.002 per 1K input tokens, $0.006 per 1K output tokens
    # Simplified: assume 70% output tokens, 30% input tokens
    function calculate_cost(tokens) {
        input_tokens = tokens * 0.3
        output_tokens = tokens * 0.7
        input_cost = (input_tokens / 1000) * 0.002
        output_cost = (output_tokens / 1000) * 0.006
        return input_cost + output_cost
    }
    {
        if (NR > 1 && $2 > 0) {
            cost = calculate_cost($2)
            print $1 "," cost "," $2
        }
    }
' > "${DATA_DIR}/cost-estimates-daily.csv"

echo "Analysis complete. Data saved to ${DATA_DIR}/"