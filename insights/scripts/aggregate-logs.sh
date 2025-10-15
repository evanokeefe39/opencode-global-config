#!/bin/bash
set -e

LOGS_DIR="${HOME}/.config/opencode/logs"
INSIGHTS_DIR="insights"
DATA_DIR="${INSIGHTS_DIR}/data"
ARCHIVE_DIR="${INSIGHTS_DIR}/archive"

# Create directories
mkdir -p "$DATA_DIR" "$ARCHIVE_DIR"

# Initialize CSV files if they don't exist
init_csv() {
    local file="$1"
    local header="$2"
    if [[ ! -f "$file" ]]; then
        echo "$header" > "$file"
    fi
}

init_csv "${DATA_DIR}/daily-aggregates.csv" "date,total_sessions,total_messages,total_tokens,avg_latency_ms,total_tools,cost_estimate,primary_agents,subagents"
init_csv "${DATA_DIR}/weekly-aggregates.csv" "period,total_sessions,total_messages,total_tokens,avg_latency_ms,total_tools,total_cost"
init_csv "${DATA_DIR}/monthly-aggregates.csv" "period,total_sessions,total_messages,total_tokens,avg_latency_ms,total_tools,total_cost"

# Get last processed date
LAST_DATE=$(cat "${DATA_DIR}/last-processed.txt" 2>/dev/null || echo "2025-01-01")
TODAY=$(date +%Y-%m-%d)

echo "Processing logs from ${LAST_DATE} to ${TODAY}"

# Function to aggregate a specific date
aggregate_date() {
    local target_date="$1"
    local log_pattern="${LOGS_DIR}/${target_date//-/*}-*.log"

    # Check if logs exist for this date
    if ! compgen -G "$log_pattern" > /dev/null; then
        echo "No logs found for ${target_date}"
        return
    fi

    echo "Aggregating ${target_date}..."

    # Initialize counters
    local sessions=0
    local messages=0
    local tokens=0
    local total_latency=0
    local latency_count=0
    local tools=0
    declare -A primary_agents
    declare -A subagents

    # Process each log file for this date
    for log_file in $log_pattern; do
        if [[ ! -f "$log_file" ]]; then continue; fi

        # Count sessions (session_end entries)
        local file_sessions=$(jq '[.[] | select(.type == "session_end")] | length' "$log_file" 2>/dev/null || echo "0")
        ((sessions += file_sessions))

        # Aggregate tokens from session_end
        local file_tokens=$(jq '[.[] | select(.type == "session_end") | .total_tokens // 0] | add' "$log_file" 2>/dev/null || echo "0")
        tokens=$((tokens + file_tokens))

        # Process messages
        while IFS= read -r line; do
            if [[ -z "$line" ]]; then continue; fi

            # Extract latency and count messages
            local latency=$(echo "$line" | jq -r '.latency // 0' 2>/dev/null || echo "0")
            local role=$(echo "$line" | jq -r '.role // ""' 2>/dev/null || echo "")

            if [[ "$role" == "assistant" ]]; then
                ((messages++))
                if (( $(echo "$latency > 0" | bc -l 2>/dev/null || echo "0") )); then
                    total_latency=$(echo "$total_latency + $latency" | bc -l 2>/dev/null || echo "$total_latency")
                    ((latency_count++))
                fi
            fi
        done < <(jq -c '.[] | select(.type == "message")' "$log_file" 2>/dev/null || echo "")

        # Count tools
        local file_tools=$(jq '[.[] | select(.type == "tool_execution")] | length' "$log_file" 2>/dev/null || echo "0")
        ((tools += file_tools))

        # Aggregate agent usage
        while IFS= read -r line; do
            if [[ -z "$line" ]]; then continue; fi

            local mode=$(echo "$line" | jq -r '.agent_mode // ""' 2>/dev/null || echo "")
            local name=$(echo "$line" | jq -r '.agent_name // ""' 2>/dev/null || echo "")

            if [[ -n "$mode" && -n "$name" ]]; then
                if [[ "$mode" == "primary" ]]; then
                    ((primary_agents[$name]++))
                else
                    ((subagents[$name]++))
                fi
            fi
        done < <(jq -c '.[] | select(.type == "agent_invocation")' "$log_file" 2>/dev/null || echo "")

    done

    # Calculate averages
    local avg_latency=0
    if ((latency_count > 0)); then
        avg_latency=$(echo "scale=1; $total_latency / $latency_count" | bc -l 2>/dev/null || echo "0")
    fi

    # Estimate cost (simplified: $0.002 per 1K input tokens, $0.006 per 1K output tokens)
    # Assuming 30% input, 70% output tokens
    local input_tokens=$(echo "$tokens * 0.3" | bc -l 2>/dev/null || echo "0")
    local output_tokens=$(echo "$tokens * 0.7" | bc -l 2>/dev/null || echo "0")
    local input_cost=$(echo "scale=4; $input_tokens * 0.002 / 1000" | bc -l 2>/dev/null || echo "0")
    local output_cost=$(echo "scale=4; $output_tokens * 0.006 / 1000" | bc -l 2>/dev/null || echo "0")
    local cost_estimate=$(echo "scale=4; $input_cost + $output_cost" | bc -l 2>/dev/null || echo "0")

    # Format agent strings
    local primary_str=""
    for agent in "${!primary_agents[@]}"; do
        primary_str+="${agent}:${primary_agents[$agent]},"
    done
    primary_str=${primary_str%,}

    local sub_str=""
    for agent in "${!subagents[@]}"; do
        sub_str+="${agent}:${subagents[$agent]},"
    done
    sub_str=${sub_str%,}

    # Check if this date already exists in CSV
    if grep -q "^${target_date}," "${DATA_DIR}/daily-aggregates.csv"; then
        # Update existing entry
        sed -i "/^${target_date},/d" "${DATA_DIR}/daily-aggregates.csv"
    fi

    # Append to daily CSV
    echo "${target_date},${sessions},${messages},${tokens},${avg_latency},${tools},${cost_estimate},\"${primary_str}\",\"${sub_str}\"" >> "${DATA_DIR}/daily-aggregates.csv"
}

# Function to generate date sequence
seq_dates() {
    local start_date="$1"
    local end_date="$2"
    local current="$start_date"

    while [[ "$current" < "$end_date" ]]; do
        echo "$current"
        current=$(date -d "$current + 1 day" +%Y-%m-%d 2>/dev/null || date -j -f "%Y-%m-%d" -v+1d "$current" +%Y-%m-%d 2>/dev/null || echo "error")
        if [[ "$current" == "error" ]]; then break; fi
    done
}

# Process each missing date
for target_date in $(seq_dates "$LAST_DATE" "$TODAY"); do
    aggregate_date "$target_date"
done

# Update weekly and monthly aggregates
update_rollups() {
    local type="$1"  # weekly or monthly
    local date_format="$2"  # %Y-%U or %Y-%m

    echo "Updating ${type} aggregates..."

    # Clear existing file and add header
    echo "period,total_sessions,total_messages,total_tokens,avg_latency_ms,total_tools,total_cost" > "${DATA_DIR}/${type}-aggregates.csv"

    # Group daily data
    tail -n +2 "${DATA_DIR}/daily-aggregates.csv" | \
    awk -F',' -v date_format="$date_format" '
        function get_period(date) {
            cmd = "date -d " date " +" date_format " 2>/dev/null || date -j -f \"%Y-%m-%d\" " date " +" date_format " 2>/dev/null"
            cmd | getline period
            close(cmd)
            return period
        }
        {
            period = get_period($1)
            sessions[period] += $2
            messages[period] += $3
            tokens[period] += $4
            latency_sum[period] += $5 * $3  # Weighted by message count
            latency_weight[period] += $3
            tools[period] += $6
            cost[period] += $7
        }
        END {
            for (p in sessions) {
                avg_lat = latency_weight[p] > 0 ? latency_sum[p] / latency_weight[p] : 0
                printf "%.0f,%.0f,%.0f,%.1f,%.0f,%.4f\n", sessions[p], messages[p], tokens[p], avg_lat, tools[p], cost[p] >> "'${DATA_DIR}'/'${type}'-aggregates.csv"
            }
        }
    '

    # Add periods to the file
    awk -F',' -v date_format="$date_format" '
        function get_period(date) {
            cmd = "date -d " date " +" date_format " 2>/dev/null || date -j -f \"%Y-%m-%d\" " date " +" date_format " 2>/dev/null"
            cmd | getline period
            close(cmd)
            return period
        }
        NR > 1 {
            period = get_period($1)
            print period "," $0
        }
    ' "${DATA_DIR}/${type}-aggregates.csv" | sort -u > "${DATA_DIR}/${type}-aggregates-temp.csv"
    mv "${DATA_DIR}/${type}-aggregates-temp.csv" "${DATA_DIR}/${type}-aggregates.csv"
}

update_rollups "weekly" "%Y-%U"
update_rollups "monthly" "%Y-%m"

# Archive processed logs (move to archive and zip by month)
echo "Archiving processed logs..."

# Find months that have logs older than 7 days
find "$LOGS_DIR" -name "*.log" -mtime +7 -print0 2>/dev/null | \
while IFS= read -r -d '' log_file; do
    # Extract month from filename (assuming format: timestamp-sessionid.log)
    filename=$(basename "$log_file")
    month=$(echo "$filename" | cut -d'-' -f1 | cut -c1-7)  # YYYY-MM

    if [[ -n "$month" && "$month" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        mkdir -p "${ARCHIVE_DIR}/${month}"
        mv "$log_file" "${ARCHIVE_DIR}/${month}/"
    fi
done

# Zip archived logs by month
for month_dir in "${ARCHIVE_DIR}"/*/; do
    if [[ -d "$month_dir" ]]; then
        month=$(basename "$month_dir")
        zip_file="${ARCHIVE_DIR}/logs-${month}.zip"

        if [[ -f "$zip_file" ]]; then
            # Add to existing zip
            (cd "$month_dir" && zip -u "$zip_file" *.log 2>/dev/null || true)
        else
            # Create new zip
            (cd "$month_dir" && zip "$zip_file" *.log 2>/dev/null || true)
        fi

        # Remove log files after zipping
        rm -f "${month_dir}"/*.log

        # Remove empty directories
        rmdir "$month_dir" 2>/dev/null || true
    fi
done

# Update last processed date
echo "$TODAY" > "${DATA_DIR}/last-processed.txt"

echo "Aggregation and archiving complete"