#!/bin/bash

README_FILE="README.md"
INSIGHTS_DIR="insights"
CHARTS_DIR="${INSIGHTS_DIR}/charts"

# Function to get latest stats
get_latest_stats() {
    local csv_file="$1"
    local column="$2"

    if [[ -f "$csv_file" ]]; then
        # Get the most recent value
        tail -n 1 "$csv_file" | cut -d',' -f"$column"
    else
        echo "N/A"
    fi
}

# Get latest metrics from daily aggregates
LATEST_TOKENS=$(get_latest_stats "${INSIGHTS_DIR}/data/daily-aggregates.csv" 4)
LATEST_LATENCY=$(get_latest_stats "${INSIGHTS_DIR}/data/daily-aggregates.csv" 5)
LATEST_COST=$(get_latest_stats "${INSIGHTS_DIR}/data/daily-aggregates.csv" 7)

# Update README with insights section
if ! grep -q "## 📊 Performance Insights" "$README_FILE"; then
    # Add insights section before Quality Badges
    sed -i '/## 📈 Quality Badges/i \
## 📊 Performance Insights\n\
\n\
*Last updated: $(date -u +"%Y-%m-%d %H:%M UTC")*\n\
\n\
### Token Usage & Cost\n\
![Token Usage Trend](insights/charts/token-usage-trend.png)\n\
![Cost Over Time](insights/charts/cost-over-time.png)\n\
\n\
**Latest Daily Stats:**\n\
- Tokens Used: '"${LATEST_TOKENS:-N/A}"'\n\
- Estimated Cost: $'"${LATEST_COST:-N/A}"'\n\
\n\
### Response Performance\n\
![Response Latency Trend](insights/charts/response-latency-trend.png)\n\
\n\
**Latest Daily Average:**\n\
- Response Latency: '"${LATEST_LATENCY:-N/A}"' ms\n\
\n\
### Tool Usage\n\
![Tool Usage Breakdown](insights/charts/tool-usage-breakdown.png)\n\
\n\
*Insights automatically updated via GitHub Actions CI.*\n\
\n' "$README_FILE"
else
    # Update existing section
    # This would be more complex - for now, just update the timestamp
    sed -i "s/Last updated: .*/Last updated: $(date -u +"%Y-%m-%d %H:%M UTC")*/" "$README_FILE"
fi

echo "README updated with latest insights"