# iCal Generator

A Python script to generate `.ics` calendar files from waste collection dates for easy import into calendars like Nextcloud, Google Calendar, or Apple Calendar.

## Features

- Command-line interface with required parameters
- Automatic output file generation
- Robust error handling and validation
- Support for multiple waste categories
- Configurable location for events

## Installation

No special installation required. The script uses only Python standard library modules.

## Usage

```bash
python ical_generator.py --input <input_file> --year <year> [--location LOCATION] [--output OUTPUT_FILE]
```

### Arguments

- `-i, --input`: Path to the input text file containing waste collection dates (required)
- `-y, --year`: Year for the calendar events (required, integer)
- `--location`: Location string for calendar events (default: "Metzingen")
- `--output`: Output ICS file path (default: input_file with .ics extension)

### Examples

```bash
# Basic usage with default location
python ical_generator.py -i dates.txt -y 2026

# Specify custom location
python ical_generator.py --input waste_calendar_2026.txt --year 2026 --location "Birkenweg Metzingen"

# Specify custom output file
python ical_generator.py -i dates.txt -y 2026 --output my_calendar.ics
```

## Input File Format

The input file should contain waste collection dates in the following format:

```
Category: DD.MM., DD.MM., DD.MM.
```

Each line represents a waste category followed by a colon and a comma-separated list of dates. Dates should be in DD.MM. format (day.month).

### Example Input File

```
Restmüll: 14.01., 28.01., 11.02., 25.02., 11.03.
Gelber Sack: 21.01., 18.02., 18.03., 15.04.
Altpapier: 24.01., 21.02., 21.03., 18.04.
```

## Getting Waste Collection Dates

1. Visit your local waste management website (e.g., [Stadtwerke Metzingen](https://www.stadtwerke-metzingen.de/de/Unsere-Angebote/Abfall/Abfallkalender))
2. Find the waste collection calendar for your area
3. Copy the dates into a text file in the format shown above

## Importing the Calendar

1. Run the script to generate the `.ics` file
2. Import the generated `.ics` file into your calendar application:
   - **Nextcloud**: Go to Calendar → Import Calendar
   - **Google Calendar**: Settings → Import & Export → Import
   - **Apple Calendar**: File → Import → From File

## Error Handling

The script includes comprehensive error handling for:
- Missing or invalid input files
- Malformed date formats
- File I/O errors
- Invalid command-line arguments

## License

This project is open source. See the main repository LICENSE file for details.
