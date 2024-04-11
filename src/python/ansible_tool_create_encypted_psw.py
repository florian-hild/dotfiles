#!/usr/bin/env python3

"""
-------------------------------------------------------------------------------
Author        : Florian Hild
Created       : 2022-09-05
Python version: >=3.12
Description   : Generate Linux User Encrypted Password for Ansible with python3
-------------------------------------------------------------------------------
"""

__VERSION__ = '1.0.0'

import getpass
import os
import base64
import ctypes

def main():
  pw=getpass.getpass()

  if ( pw == getpass.getpass("Confirm: ") ):
    crypt = ctypes.CDLL("libcrypt.so.2").crypt
    crypt.restype = ctypes.c_char_p
    salt = base64.b64encode(os.urandom(16), altchars=b"./").rstrip(b"=")

    print("\n"+crypt(pw.encode('utf-8'), b"$6$"+salt).decode())
  else:
    print("Error: Passwords do not match.")
    exit(1)

if __name__ == '__main__':
  main()
