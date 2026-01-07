#!/usr/bin/env python3

import argparse
import sys
from datetime import datetime
from pathlib import Path

# ICS Header and Footer
ICS_HEADER = """BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Waste Calendar Generator//Python//EN
"""
ICS_FOOTER = "END:VCALENDAR"

# ICS Event Template
ICS_EVENT_TEMPLATE = """BEGIN:VEVENT
SUMMARY:{summary}
DESCRIPTION:{description}
LOCATION:{location}
DTSTART;VALUE=DATE:{start}
DTEND;VALUE=DATE:{end}
END:VEVENT
"""


def parse_input_file(file_path: str) -> list:
    """
    Parse the input file containing waste collection dates.

    Args:
        file_path: Path to the input text file

    Returns:
        List of tuples containing (category, list_of_dates)
    """
    events = []
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            for line_num, line in enumerate(file, 1):
                line = line.strip()
                if not line or ":" not in line:
                    continue
                try:
                    category, dates_str = line.split(":", 1)
                    dates = [
                        date.strip().rstrip(".")
                        for date in dates_str.strip().split(",")
                    ]
                    events.append((category.strip(), dates))
                except ValueError as e:
                    print(
                        f"Warning: Skipping malformed line {line_num}: {line} ({e})",
                        file=sys.stderr,
                    )
    except FileNotFoundError:
        print(f"Error: Input file '{file_path}' not found.", file=sys.stderr)
        sys.exit(1)
    except IOError as e:
        print(f"Error: Could not read input file '{file_path}': {e}", file=sys.stderr)
        sys.exit(1)

    if not events:
        print("Error: No valid events found in input file.", file=sys.stderr)
        sys.exit(1)

    return events


def format_ics_date(date_str: str, year: int) -> str:
    """
    Convert date string to ICS format.

    Args:
        date_str: Date in DD.MM format
        year: Year to append

    Returns:
        Date in YYYYMMDD format
    """
    try:
        date = datetime.strptime(f"{date_str}.{year}", "%d.%m.%Y")
        return date.strftime("%Y%m%d")
    except ValueError as e:
        print(f"Error: Invalid date format '{date_str}': {e}", file=sys.stderr)
        sys.exit(1)


def generate_ics(events: list, year: int, location: str) -> str:
    """
    Generate ICS content from events.

    Args:
        events: List of (category, dates) tuples
        year: Year for the calendar
        location: Location string for events

    Returns:
        Complete ICS calendar content
    """
    content = ICS_HEADER
    for category, dates in events:
        for date in dates:
            start = format_ics_date(date, year)
            end = start  # Same day event
            content += ICS_EVENT_TEMPLATE.format(
                summary=category,
                description=f"Waste collection: {category}",
                location=location,
                start=start,
                end=end,
            )
    content += ICS_FOOTER
    return content


def main():
    parser = argparse.ArgumentParser(
        description="Generate ICS calendar file from waste collection dates.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Example:
  python ical_generator.py --input dates.txt --year 2026 --location "Birkenweg Metzingen"

Input file format:
  Category: DD.MM., DD.MM., ...
  e.g., Restmüll: 14.01., 28.01., 11.02.
        """,
    )
    parser.add_argument(
        "-i",
        "--input",
        dest="input_file",
        required=True,
        help="Path to input text file containing waste collection dates",
    )
    parser.add_argument(
        "-y", "--year", type=int, required=True, help="Year for the calendar events"
    )
    parser.add_argument(
        "--location",
        default="Metzingen",
        help="Location for calendar events (default: Metzingen)",
    )
    parser.add_argument(
        "--output",
        help="Output ICS file path (default: input_file with .ics extension)",
    )

    args = parser.parse_args()

    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Error: Input file '{args.input_file}' does not exist.", file=sys.stderr)
        sys.exit(1)

    output_file = args.output or input_path.with_suffix(".ics")

    print(f"Reading input file: {args.input_file}")
    events = parse_input_file(args.input_file)

    print(f"Generating ICS file for year {args.year} and location '{args.location}'...")
    ics_content = generate_ics(events, args.year, args.location)

    try:
        with open(output_file, "w", encoding="utf-8") as file:
            file.write(ics_content)
        print(f"ICS file generated successfully: {output_file}")
    except IOError as e:
        print(
            f"Error: Could not write output file '{output_file}': {e}", file=sys.stderr
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
