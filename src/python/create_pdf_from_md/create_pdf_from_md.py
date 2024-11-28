#!/usr/bin/env python3

"""
-------------------------------------------------------------------------------
Author        : Florian Hild
Created       : 2024-11-26
Python version: 3.x
Description   : pango system package required
-------------------------------------------------------------------------------
"""

__VERSION__ = '1.0.0'

import argparse
import os
import re
import markdown2
from weasyprint import HTML


parser = argparse.ArgumentParser(
  description='Convert markdown file to pdf file',
  prog='create_pdf_from_md',
  usage='%(prog)s [options]',
  add_help=False,
)

parser.add_argument(
  '-V', '--version',
  help="Print version number and exit.",
  action='version',
  version=f"%(prog)s version {__VERSION__}",
)

parser.add_argument(
  '-h', '--help',
  help='Print a short help page describing the options available and exit.',
  action='help',
)

parser.add_argument(
  '-i', '--input',
  help='Markdown input file',
  type=argparse.FileType('r'),
  required=True,
)

parser.add_argument(
  '-o', '--output',
  help='PDF output file',
  type=argparse.FileType('w'),
)

args = parser.parse_args()




def md_to_pdf(md_file, pdf_file):
    # Read the Markdown file
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()

    # Replace backslashes at the end of lines with actual newlines
    md_content = re.sub(r'\\+\s*$', '$', md_content, flags=re.MULTILINE)

    # Convert Markdown to HTML
    html_content = markdown2.markdown(md_content, extras=["fenced-code-blocks"])

    # Define CSS inline
    css_inline = """
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
        }
        pre {
            background-color: #f4f4f4;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: "Courier New", Courier, monospace;
            white-space: pre-wrap; /* Ensure newlines are respected */
        }
    </style>
    """

    # Create complete HTML with inline CSS
    html_with_style = f"""
    <!DOCTYPE html>
    <html>
    <head>
        {css_inline}
    </head>
    <body>
    {html_content}
    </body>
    </html>
    """

    # Generate PDF from HTML
    print("Generating " + pdf_file)
    HTML(string=html_with_style).write_pdf(pdf_file)




def main():
    if args.output:
      output_file = args.output.name
    else:
      output_file = os.path.splitext(args.input.name)[0] + ".pdf"

    md_to_pdf(args.input.name, output_file)




if __name__ == '__main__':
  main()


