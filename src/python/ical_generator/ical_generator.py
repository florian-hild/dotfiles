#!/usr/bin/env python3

from datetime import datetime

# Parameters
YEAR = 2025
LOCATION = "Birkenweg Metzingen"
INPUT_FILE = "waste_calendar_2025.txt"
OUTPUT_FILE = "waste_calendar_2025.ics"

# ICS Header and Footer
ICS_HEADER = """BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//SabreDAV//SabreDAV//EN
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


# Parse the input file
def parse_input_file(file_path):
    events = []
    with open(file_path, "r", encoding="utf-8") as file:
        for line in file:
            if ":" in line:
                category, dates = line.split(":")
                dates = dates.strip().split(", ")
                events.append((category.strip(), dates))
    return events


# Generate ICS date format
def format_ics_date(date_str, year):
    # Remove trailing dot if it exists
    date_str = date_str.rstrip(".")

    date = datetime.strptime(date_str + f".{year}", "%d.%m.%Y")
    return date.strftime("%Y%m%d")


# Generate ICS content
def generate_ics(events, year, location):
    content = ICS_HEADER
    for category, dates in events:
        for date in dates:
            start = format_ics_date(date, year)
            end = start  # Same day event
            content += ICS_EVENT_TEMPLATE.format(
                summary=category,
                description=category,
                location=location,
                start=start,
                end=end,
            )
    content += ICS_FOOTER
    return content


# Main function
def main():
    print(f"Reading input file: {INPUT_FILE}")
    events = parse_input_file(INPUT_FILE)
    print(f"Generating ICS file for year {YEAR} and location '{LOCATION}'...")
    ics_content = generate_ics(events, YEAR, LOCATION)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as file:
        file.write(ics_content)
    print(f"ICS file generated successfully: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
