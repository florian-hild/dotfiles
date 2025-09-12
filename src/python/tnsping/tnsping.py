#!/usr/bin/env python3

################################################################################
# Script Name : TNS Ping via LDAP
# Author      : F.Hild
# Date        : 12.09.2025
# Description : Oracle TNS ping utility that resolves TNS aliases via LDAP
#               and tests connectivity to Oracle database servers.
#
# Dependencies: python-ldap
################################################################################

import re
import socket
import sys
import time

import ldap

# Configuration Constants
LDAP_HOST = "ldap.sup-logistik.de"
LDAP_PORT = 389
LDAP_BASE_DN = "dc=sup-logistik,dc=de"

# TNS Ping Configuration
TNS_PING_TIMEOUT = 5  # seconds for each connection attempt
TNS_PING_ATTEMPTS = 1  # number of ping attempts


def print_usage():
    program = sys.argv[0]
    print(
        f"""
Usage:
  {program} <net_service_name> [count]

Description:
  Test Oracle TNS connectivity by:
    - Resolving the alias via LDAP
    - Performing ping attempts to the database server

Options:
  <net_service_name>    Name of the Oracle TNS alias to test (as defined in LDAP)
  [count]               Number of ping attempts (optional, default: {TNS_PING_ATTEMPTS})

Example:
  {program} sup193u-cl          # Uses default {TNS_PING_ATTEMPTS} attempts
  {program} sup193u-cl 10       # Uses 10 attempts
"""
    )
    exit(1)


def resolve_tns_alias(alias):
    """Resolve TNS alias to a connect descriptor via LDAP (python-ldap)."""

    print(f"Using LDAP adapter ({LDAP_HOST}:{LDAP_PORT}) to resolve alias '{alias}'")

    conn = None
    try:
        uri = f"ldap://{LDAP_HOST}:{LDAP_PORT}"
        conn = ldap.initialize(uri)
        conn.simple_bind_s()  # anonymous bind, adjust if needed

        search_filter = f"(cn={alias})"
        result = conn.search_s(LDAP_BASE_DN, ldap.SCOPE_SUBTREE, search_filter, ["orclNetDescString"])

        if not result:
            raise Exception(f"TNS alias '{alias}' not found in LDAP directory")

        if "orclNetDescString" not in result[0][1]:
            raise Exception(f"TNS alias '{alias}' found but has no connection descriptor")

        desc = result[0][1]["orclNetDescString"][0].decode("utf-8")
        print(f"Attempting to contact {desc}")
        return desc

    except ldap.LDAPError as e:
        raise Exception(f"LDAP error: {e}")
    except Exception as e:
        raise Exception(f"Error resolving TNS alias: {e}")
    finally:
        if conn is not None:
            try:
                conn.unbind()
            except Exception:
                pass


def parse_descriptor(desc):
    """Extract HOST and PORT from TNS descriptor."""

    # Clean up the descriptor string
    desc = desc.strip()

    # More flexible regex patterns to handle various TNS descriptor formats
    host_match = re.search(r"HOST\s*=\s*([^)\s]+)", desc, re.IGNORECASE)
    port_match = re.search(r"PORT\s*=\s*(\d+)", desc, re.IGNORECASE)

    if not host_match:
        raise Exception("Could not parse HOST from descriptor")
    if not port_match:
        raise Exception("Could not parse PORT from descriptor")

    host = host_match.group(1).strip()
    port = int(port_match.group(1))

    return host, port


def build_tns_ping_packet():
    """Build an Oracle TNS CONNECT packet exactly matching the tcpdump output.

    This creates a 99-byte TNS CONNECT packet that matches the structure
    seen in the tcpdump analysis. The packet includes proper TNS headers,
    version information, and connect data.
    """

    packet_bytes = bytes(
        [
            # Bytes 0-7: TNS Header
            0x00,
            0x63,  # Length: 99 bytes
            0x00,
            0x00,  # Packet checksum
            0x01,
            0x00,  # Type: CONNECT, flags
            0x00,
            0x00,  # Header checksum
            # Bytes 8-23: Version and service options
            0x01,
            0x3B,  # Version
            0x01,
            0x2C,  # Compatible version
            0x00,
            0x00,  # Service options
            0x20,
            0x00,  # Session data unit size
            0xFF,
            0xFF,  # Maximum SDU size
            0x7F,
            0x08,  # Maximum TDU size
            # Bytes 24-31: Protocol characteristics
            0x00,
            0x00,  # Protocol characteristics
            0x01,
            0x00,  # Line turnaround
            0x00,
            0x1D,  # Value of 1 in hardware
            0x00,
            0x46,  # Connect data length
            # Bytes 32-63: 32 bytes of padding/reserved space
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,  # 8 bytes
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,  # 8 bytes
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,  # 8 bytes
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,  # 8 bytes
            # Bytes 64-73: Structure before connect data
            0x20,
            0x00,
            0x00,
            0x20,  # 4 bytes
            0x00,
            0x00,
            0x00,
            0x00,  # 4 bytes
            0x00,
            0x00,  # 2 bytes
            # Bytes 74-98: Connect data string "(CONNECT_DATA=(COMMAND=ping))" (25 bytes)
            0x28,
            0x43,
            0x4F,
            0x4E,
            0x4E,
            0x45,  # "(CONNE" (6 bytes)
            0x43,
            0x54,
            0x5F,
            0x44,
            0x41,
            0x54,
            0x41,
            0x3D,
            0x28,
            0x43,
            0x4F,
            0x4D,
            0x4D,
            0x41,
            0x4E,
            0x44,  # "CT_DATA=(COMMAND" (16 bytes)
            0x3D,
            0x70,
            0x69,
            0x6E,
            0x67,
            0x29,
            0x29,  # "=ping))" (7 bytes)
        ]
    )

    return packet_bytes


def tnsping(host, port, attempts=TNS_PING_ATTEMPTS, timeout=TNS_PING_TIMEOUT):
    """Test socket connectivity (like tnsping)."""

    packet = build_tns_ping_packet()

    for i in range(attempts):
        start = time.time()
        try:
            with socket.create_connection((host, port), timeout=timeout) as s:
                # print(f"Send data ({i+1}):\n{packet}")
                s.sendall(packet)

                # receive minimal response (TNS header + some data)
                resp = s.recv(1024)
                # print(f"Response data ({i+1}):\n{resp}")

                elapsed = time.time() - start
                elapsed_ms = int(elapsed * 1000)

                if resp:
                    print(f"OK ({elapsed_ms} msec)")
                else:
                    print("ERROR, no response")

        except socket.timeout:
            elapsed_ms = int((time.time() - start) * 1000)
            print(f"TIMEOUT after {elapsed_ms} msec")
        except Exception as e:
            elapsed_ms = int((time.time() - start) * 1000)
            print(f"ERROR: {e} ({elapsed_ms} msec)")


def main():
    """Main function to handle command line arguments and execute TNS ping."""

    if len(sys.argv) <= 1 or len(sys.argv) >= 4:
        print_usage()

    alias = sys.argv[1].strip()

    # Use custom number of attempts if provided, otherwise use default
    attempts = TNS_PING_ATTEMPTS  # Use global default
    if len(sys.argv) == 3:  # If third argument is provided
        try:
            attempts = int(sys.argv[2])
            if attempts <= 0:
                print("ERROR: Number of attempts must be positive")
                sys.exit(1)
        except ValueError:
            print("ERROR: Number of attempts must be a valid integer")
            sys.exit(1)

    if not alias:
        print("ERROR: TNS alias cannot be empty")
        sys.exit(1)

    try:
        print("TNS Ping Utility")
        desc = resolve_tns_alias(alias)
        host, port = parse_descriptor(desc)
        tnsping(host, port, attempts, TNS_PING_TIMEOUT)

    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(130)  # Standard exit code for SIGINT
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
