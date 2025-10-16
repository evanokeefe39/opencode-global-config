import os
import json
import csv
import datetime
import glob
from collections import defaultdict

log_dir = 'logs'
csv_file = 'token_usage_daily.csv'
chart_file = 'token_usage_chart.md'

def main():
    log_files = glob.glob(os.path.join(log_dir, '*.log'))
    if not log_files:
        print("No log files found in logs/")
        return

    daily_totals = defaultdict(lambda: {'input': 0, 'output': 0, 'reasoning': 0, 'cache_read': 0, 'cache_write': 0, 'total': 0})

    for log_file in log_files:
        try:
            with open(log_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                     try:
                         entry = json.loads(line)
                         if entry.get('type') == 'token_usage':
                              input_tokens = entry.get('input', 0)
                              output_tokens = entry.get('output', 0)
                              reasoning_tokens = entry.get('reasoning', 0)
                              cache_read = entry.get('cache_read', 0)
                              cache_write = entry.get('cache_write', 0)
                              total = input_tokens + output_tokens + reasoning_tokens + cache_read + cache_write
                              if total > 0:
                                  date = datetime.date.fromtimestamp(entry['timestamp'] / 1000)
                                  daily_totals[date]['input'] += input_tokens
                                  daily_totals[date]['output'] += output_tokens
                                  daily_totals[date]['reasoning'] += reasoning_tokens
                                  daily_totals[date]['cache_read'] += cache_read
                                  daily_totals[date]['cache_write'] += cache_write
                                  daily_totals[date]['total'] += total
                    except json.JSONDecodeError:
                        continue
        except FileNotFoundError:
            print(f"Log file not found: {log_file}")
            continue

    if not daily_totals:
        print("No token usage data found")
        return

    # Write CSV
    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['date', 'input_tokens', 'output_tokens', 'reasoning_tokens', 'cache_read', 'cache_write', 'total_tokens'])
        for date in sorted(daily_totals):
            data = daily_totals[date]
            writer.writerow([date.isoformat(), data['input'], data['output'], data['reasoning'], data['cache_read'], data['cache_write'], data['total']])

    # Generate Markdown table
    table = '| Date | Input Tokens | Output Tokens | Reasoning Tokens | Cache Read | Cache Write | Total Tokens |\n'
    table += '|------|--------------|---------------|------------------|------------|-------------|--------------|\n'
    for date in sorted(daily_totals, reverse=True):  # Most recent first
        data = daily_totals[date]
        table += f'| {date} | {data["input"]:,} | {data["output"]:,} | {data["reasoning"]:,} | {data["cache_read"]:,} | {data["cache_write"]:,} | {data["total"]:,} |\n'

    # Update README.md
    readme_path = 'README.md'
    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the Performance Insights section
        start_marker = '## 📊 Performance Insights'
        end_marker = '## 📈 Quality Badges'

        start_idx = content.find(start_marker)
        end_idx = content.find(end_marker)

        if start_idx != -1 and end_idx != -1:
            # Replace the section between markers
            before = content[:start_idx + len(start_marker)]
            after = content[end_idx:]

            # Generate the new section
            new_section = f'\n\n*Last updated: {datetime.datetime.now().strftime("%Y-%m-%d %H:%M UTC")}*\n\n### Daily Token Usage Summary\n\n{table}\n\n'

            updated_content = before + new_section + after

            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(updated_content)

            print(f"Updated {readme_path} with token usage table")
        else:
            print("Could not find Performance Insights section in README.md")

    except FileNotFoundError:
        print(f"README.md not found at {readme_path}")

    print(f"Processed {len(log_files)} log files. Outputs: {csv_file}")

if __name__ == '__main__':
    main()