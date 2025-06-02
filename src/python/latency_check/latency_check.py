#!/usr/bin/env python3

"""
-------------------------------------------------------------------------------
Author        : Florian Hild
Created       : 2025-05-13
Python version: 3.x
Description   : Ping monitor with high latency detection and summary
-------------------------------------------------------------------------------
"""

import argparse
import subprocess
import time
from datetime import datetime
from typing import List, Optional


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Ping monitor with high latency detection and summary"
    )
    parser.add_argument(
        "target",
        nargs="?",
        default="1.1.1.1",
        help="Target host to ping (default: 1.1.1.1)",
    )
    parser.add_argument(
        "-d",
        "--duration",
        type=int,
        default=60,
        help="Duration in minutes (default: 60)",
    )
    parser.add_argument(
        "-i",
        "--interval",
        type=int,
        default=1,
        help="Ping interval in seconds (default: 1)",
    )
    parser.add_argument(
        "-t",
        "--threshold",
        type=float,
        default=50.0,
        help="Latency threshold in ms for warnings (default: 50.0)",
    )
    return parser.parse_args()


def ping_once(target: str) -> Optional[float]:
    try:
        result = subprocess.run(
            ["ping", "-c", "1", target], capture_output=True, text=True
        )
        if result.returncode == 0 and "time=" in result.stdout:
            latency = float(result.stdout.split("time=")[-1].split()[0])
            return latency
        return None
    except Exception:
        return None


def print_header(target: str, duration: int, interval: int, threshold: float) -> None:
    print(f"""Ping Monitor:
  Target            : {target}
  Duration          : {duration} min
  Interval          : {interval} sec
  Latency threshold : {threshold} ms
""")


def print_summary(
    target: str, start_time: datetime, sent: int, lost: int, latencies: List[float]
) -> None:
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds() / 60
    received = sent - lost
    avg_latency = sum(latencies) / len(latencies) if latencies else 0
    loss_pct = (lost / sent) * 100 if sent else 0

    print("\nSummary:")
    print(f"  Target           : {target}")
    print(f"  Duration         : {duration:.2f} minutes")
    print(f"  Packets sent     : {sent}")
    print(f"  Packets received : {received}")
    print(f"  Packets lost     : {lost} ({loss_pct:.2f}%)")
    print(f"  Average latency  : {avg_latency:.2f} ms")


def monitor(target: str, duration_min: int, interval: int, threshold: float) -> None:
    end_time = time.time() + (duration_min * 60)
    sent = 0
    lost = 0
    latencies = []
    start_time = datetime.now()

    try:
        while time.time() < end_time:
            timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
            sent += 1
            latency = ping_once(target)

            if latency is not None:
                latencies.append(latency)
                if latency > threshold:
                    print(
                        f"{timestamp} WARN  High latency: {latency:.2f} ms to {target}"
                    )
            else:
                lost += 1
                print(f"{timestamp} ERROR Host {target} unreachable")

            time.sleep(interval)

    except KeyboardInterrupt:
        print("\nInterrupted by user. Finalizing...")

    print_summary(target, start_time, sent, lost, latencies)


def main() -> None:
    args = parse_args()
    print_header(args.target, args.duration, args.interval, args.threshold)
    monitor(args.target, args.duration, args.interval, args.threshold)


if __name__ == "__main__":
    main()
