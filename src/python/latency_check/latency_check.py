#!/usr/bin/env python3

"""
-------------------------------------------------------------------------------
Author        : Florian Hild
Created       : 2025-05-13
Python version: 3.x
Description   : Ping monitor with high latency detection and summary
-------------------------------------------------------------------------------
"""

import time
import subprocess
from datetime import datetime

__VERSION__ = "1.0.0"

# Configuration
target = "1.1.1.1"
duration_minutes = 60  # duration in minutes
interval = 1  # in seconds
latency_threshold = 50.0  # in ms


def main():
    duration_seconds = duration_minutes * 60
    end_time = time.time() + duration_seconds
    sent = 0
    lost = 0
    latencies = []

    start_ts = datetime.now()

    while time.time() < end_time:
        timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S%z")
        sent += 1

        try:
            result = subprocess.run(["ping", "-c", "1", target], capture_output=True, text=True)

            if result.returncode == 0 and "time=" in result.stdout:
                latency = float(result.stdout.split("time=")[-1].split()[0])
                latencies.append(latency)
                if latency > latency_threshold:
                    print(f"{timestamp} WARN  High latency: {latency:.2f} ms to {target}")
            else:
                lost += 1
                print(f"{timestamp} ERROR Host {target} unreachable")

        except Exception as e:
            lost += 1
            print(f"{timestamp} ERROR Exception: {str(e)}")

        time.sleep(interval)

    end_ts = datetime.now()
    total_duration = (end_ts - start_ts).total_seconds()
    received = sent - lost
    avg_latency = sum(latencies) / len(latencies) if latencies else 0
    packet_loss_pct = (lost / sent) * 100

    # Summary
    print("\nSummary:")
    print(f"  Target           : {target}")
    print(f"  Duration         : {total_duration:.2f} seconds")
    print(f"  Packets sent     : {sent}")
    print(f"  Packets received : {received}")
    print(f"  Packets lost     : {lost} ({packet_loss_pct:.2f}%)")
    print(f"  Average latency  : {avg_latency:.2f} ms")


if __name__ == "__main__":
    main()
