#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["passlib>=1.7"]
# ///

"""
-------------------------------------------------------------------------------
Author        : Florian Hild
Created       : 2022-09-05
Python version: >=3.12
Description   : Generate Linux User Encrypted Password for Ansible with python3
-------------------------------------------------------------------------------
"""

__VERSION__ = '2.1.0'

import argparse
import getpass
import sys

from passlib.hash import sha512_crypt

def parse_args():
  parser = argparse.ArgumentParser(
    description='Generate Linux user encrypted password (SHA-512 crypt) for Ansible.',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="""\
Examples:
  # Interactive: prompts for password (hidden) and confirmation
  %(prog)s
  Password:
  Confirm:
  $6$rounds=656000$juKkQ033lUS9wsMG$DAPfFbWVZTqZM...

  # Use the hash in an Ansible task
  - name: Create user
    ansible.builtin.user:
      name: deploy
      password: "{{ deploy_password_hash }}"
""",
  )
  parser.add_argument(
    '-V', '--version',
    action='version',
    version=f'%(prog)s {__VERSION__}',
  )
  return parser.parse_args()

def main():
  parse_args()
  pw = getpass.getpass()

  if pw == getpass.getpass("Confirm: "):
    print("\n" + sha512_crypt.hash(pw))
  else:
    print("Error: Passwords do not match.", file=sys.stderr)
    sys.exit(1)

if __name__ == '__main__':
  main()
