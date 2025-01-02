# iCal Generator

Easily create an `.ics` file to import into your calendar (e.g., Nextcloud).

### Steps

1. **Download Waste Calendar Dates**\
   Get the waste collection dates from [Stadtwerke Metzingen](https://www.stadtwerke-metzingen.de/de/Unsere-Angebote/Abfall/Abfallkalender).

2. **Format the Dates**\
   Copy the dates into a file (`waste_calendar_2025.txt`) in the following format:
   ```
   Restmüll: 02.01., 15.01., 29.01., 12.02., 26.02., 12.03., 26.03., 09.04., 24.04., 07.05., 21.05., 04.06., 18.06., 02.07., 16.07., 30.07., 13.08., 27.08., 10.09., 24.09., 08.10., 22.10., 05.11., 19.11., 03.12., 17.12., 31.12.
   Gelber Sack: 22.01., 19.02., 19.03., 16.04., 14.05., 12.06., 09.07., 06.08., 03.09., 01.10., 29.10., 26.11., 24.12.
   Altpapier: 25.01., 22.02., 22.03., 26.04., 24.05., 28.06., 19.07., 23.08., 20.09., 18.10., 15.11., 13.12.
   ```
3. **Set Parameters in the Script**\
   Open the Python script and adjust these parameters:
   ```python
   YEAR = 2025
   LOCATION = "Birkenweg Metzingen"
   INPUT_FILE = "waste_calendar_2025.txt"
   OUTPUT_FILE = "waste_calendar_2025.ics"
   ```
   Run the Script
   Execute the script to generate the .ics file.

4. **Import the File**\
   Import the generated .ics file into your Nextcloud calendar.