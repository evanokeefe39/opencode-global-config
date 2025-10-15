#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import json

# Set style
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

# Directories
DATA_DIR = Path("insights/data")
CHARTS_DIR = Path("insights/charts")
CHARTS_DIR.mkdir(exist_ok=True)

def create_token_usage_chart():
    """Create token usage over time chart"""
    df = pd.read_csv(DATA_DIR / "token-usage-daily.csv")
    df['date'] = pd.to_datetime(df['date'])
    df = df.sort_values('date')

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.plot(df['date'], df['total_tokens'], marker='o', linewidth=2, markersize=4)
    ax.set_title('Daily Token Usage Over Time', fontsize=14, fontweight='bold')
    ax.set_xlabel('Date')
    ax.set_ylabel('Total Tokens')
    ax.grid(True, alpha=0.3)
    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.savefig(CHARTS_DIR / "token-usage-trend.png", dpi=150, bbox_inches='tight')
    plt.close()

def create_latency_chart():
    """Create response latency chart"""
    df = pd.read_csv(DATA_DIR / "response-latency-daily.csv")
    df['date'] = pd.to_datetime(df['date'])
    df = df.sort_values('date')

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.plot(df['date'], df['avg_latency_ms'], marker='s', color='orange', linewidth=2, markersize=4)
    ax.set_title('Average Response Latency Over Time', fontsize=14, fontweight='bold')
    ax.set_xlabel('Date')
    ax.set_ylabel('Average Latency (ms)')
    ax.grid(True, alpha=0.3)
    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.savefig(CHARTS_DIR / "response-latency-trend.png", dpi=150, bbox_inches='tight')
    plt.close()

def create_tool_usage_chart():
    """Create tool usage breakdown chart"""
    df = pd.read_csv(DATA_DIR / "tool-invocations-daily.csv")

    # Get latest data
    latest_date = df['date'].max()
    latest_data = df[df['date'] == latest_date]

    if not latest_data.empty:
        fig, ax = plt.subplots(figsize=(10, 6))
        latest_data.groupby('tool_name')['invocations'].sum().plot(kind='bar', ax=ax)
        ax.set_title(f'Tool Usage Breakdown ({latest_date})', fontsize=14, fontweight='bold')
        ax.set_xlabel('Tool Name')
        ax.set_ylabel('Total Invocations')
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()

        plt.savefig(CHARTS_DIR / "tool-usage-breakdown.png", dpi=150, bbox_inches='tight')
        plt.close()

def create_cost_chart():
    """Create cost over time chart"""
    df = pd.read_csv(DATA_DIR / "cost-estimates-daily.csv", header=None,
                    names=['date', 'cost', 'tokens'])
    df['date'] = pd.to_datetime(df['date'])
    df = df.sort_values('date')

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Cost chart
    ax1.plot(df['date'], df['cost'], marker='^', color='red', linewidth=2, markersize=4)
    ax1.set_title('Estimated Daily Cost Over Time', fontsize=14, fontweight='bold')
    ax1.set_ylabel('Cost ($)')
    ax1.grid(True, alpha=0.3)

    # Token chart
    ax2.plot(df['date'], df['tokens'], marker='o', color='blue', linewidth=2, markersize=4)
    ax2.set_title('Token Usage Correlation', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Date')
    ax2.set_ylabel('Tokens')
    ax2.grid(True, alpha=0.3)

    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.savefig(CHARTS_DIR / "cost-over-time.png", dpi=150, bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    print("Generating performance charts...")

    try:
        create_token_usage_chart()
        print("✓ Token usage chart created")
    except Exception as e:
        print(f"✗ Failed to create token chart: {e}")

    try:
        create_latency_chart()
        print("✓ Response latency chart created")
    except Exception as e:
        print(f"✗ Failed to create latency chart: {e}")

    try:
        create_tool_usage_chart()
        print("✓ Tool usage chart created")
    except Exception as e:
        print(f"✗ Failed to create tool usage chart: {e}")

    try:
        create_cost_chart()
        print("✓ Cost chart created")
    except Exception as e:
        print(f"✗ Failed to create cost chart: {e}")

    print("Chart generation complete!")