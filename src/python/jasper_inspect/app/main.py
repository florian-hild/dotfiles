#!/usr/bin/env python3
"""
jasper_inspect.py

Inspect .jasper (compiled JasperReports) files and extract metadata useful for admins.

Features:
 - Detect Java serialization header
 - Scan embedded class files (CAFEBABE) and read classfile major version
 - Parse Java serialized object graph via javaobj-py3 (safe, no Java execution)
 - Walk object graph to find report name, parameters, fields, variables, subreports
 - JSON / detailed output and human-friendly summary
"""

from __future__ import annotations

import argparse
import json
import os
import re
import struct
import sys
from typing import Any, Dict, List, Set, Tuple

try:
    import javaobj.v2 as javaobj
except Exception:
    javaobj = None  # handled later

# optional pretty table
try:
    from tabulate import tabulate
except Exception:
    tabulate = None

JAVA_SERIAL_HEADER = b"\xac\xed\x00\x05"  # Java serialization stream magic
CLASS_MAGIC = b"\xca\xfe\xba\xbe"

# Map of classfile major version to common Java versions (partial)
MAJOR_TO_JAVA = {
    45: "1.1",
    46: "1.2",
    47: "1.3",
    48: "1.4",
    49: "5",
    50: "6",
    51: "7",
    52: "8",
    53: "9",
    54: "10",
    55: "11",
    56: "12",
    57: "13",
    58: "14",
    59: "15",
    60: "16",
    61: "17",
    62: "18",
    63: "19",
    64: "20",
    65: "21",
}


def find_classfiles(data: bytes) -> List[Tuple[int, int, int]]:
    """
    Find occurrences of CAFEBABE and parse minor/major version that follow.
    Returns list of tuples: (offset_of_magic, minor, major)
    """
    res = []
    idx = 0
    while True:
        idx = data.find(CLASS_MAGIC, idx)
        if idx == -1:
            break
        # ensure enough bytes after magic for minor+major (4 bytes)
        if idx + 8 <= len(data):
            # bytes after magic: minor (2 bytes), major (2 bytes), big-endian
            minor, major = struct.unpack(">HH", data[idx + 4 : idx + 8])
            res.append((idx, minor, major))
        else:
            res.append((idx, None, None))
        idx += 4
    return res


def extract_ascii_strings(data: bytes, min_len: int = 4) -> List[str]:
    """
    Extract ASCII/UTF-8-like strings from binary for heuristic fallback.
    """
    # decode as latin1 to preserve bytes and then regex ASCII-range substrings
    s = data.decode("latin1", errors="ignore")
    # find sequences of printable chars (including space) of length >= min_len
    candidates = re.findall(r"[\x20-\x7E]{%d,}" % min_len, s)
    return candidates


def safe_parse_with_javaobj(data: bytes) -> Tuple[Any, List[str]]:
    """
    Try to parse Java serialized stream using javaobj.v2.
    Returns (root_object, warnings).
    """
    warnings = []
    if javaobj is None:
        warnings.append("javaobj-py3 not installed; skipping javaobj parse.")
        return None, warnings
    try:
        root = javaobj.loads(data, ignore_remaining_data=True)
        return root, warnings
    except Exception as e:
        warnings.append(f"javaobj parse failed: {e}")
        return None, warnings


def is_serialized_stream(data: bytes) -> bool:
    return data.startswith(JAVA_SERIAL_HEADER)


def collect_from_parsed(obj: Any, max_depth: int = 8):
    """
    Walk parsed javaobj structures and collect metadata.
    Returns a dict with keys: classes, strings, params, fields, variables, subreports, names
    This function uses heuristics and scans for matching keys/strings.
    """
    seen = set()
    classes: Set[str] = set()
    strings: Set[str] = set()
    names: Set[str] = set()
    params: Set[str] = set()
    fields: Set[str] = set()
    variables: Set[str] = set()
    subreports: Set[str] = set()

    def walk(x, depth=0):
        if depth > max_depth:
            return
        oid = id(x)
        if oid in seen:
            return
        seen.add(oid)

        # javaobj types have reprs — handle common python types and javaobj wrappers
        # Heuristics for javaobj.v2 types:
        # - javaobj.JavaObject -> has classdesc.name and fields (dict-like accessible via .__dict__?)
        # - Many scalar values are native python types

        # detect class names via attributes
        try:
            cname = getattr(x, "__class__", None)
        except Exception:
            cname = None

        # handle mapping-like
        if isinstance(x, dict):
            # check keys and values
            for k, v in x.items():
                try:
                    if isinstance(k, str):
                        strings.add(k)
                        low = k.lower()
                        if "param" in low or "parameter" in low:
                            params.add(k)
                        if "field" in low:
                            fields.add(k)
                        if "subreport" in low or "subreportkey" in low:
                            subreports.add(k)
                        if "var" in low or "variable" in low:
                            variables.add(k)
                    # walk both
                except Exception:
                    pass
                walk(k, depth + 1)
                walk(v, depth + 1)
            return

        # handle lists/tuples/sets
        if isinstance(x, (list, tuple, set)):
            for it in x:
                walk(it, depth + 1)
            return

        # handle javaobj.v2 JavaInstance (has field_data attribute)
        if hasattr(x, "field_data") and isinstance(getattr(x, "field_data", None), dict):
            # javaobj.v2 structure: JavaInstance has classdesc and field_data
            classdesc = getattr(x, "classdesc", None)
            if classdesc is not None:
                cname = getattr(classdesc, "name", None)
                if cname:
                    classes.add(str(cname))
                    # Check if class name itself indicates subreport/param/field
                    cname_lower = cname.lower()
                    if "subreport" in cname_lower:
                        # This is a subreport object - try to get its name/key
                        for cd, fld_dict in x.field_data.items():
                            for field_obj, value in fld_dict.items():
                                fname = getattr(field_obj, "name", None)
                                if fname:
                                    # Convert value to string if it's a JavaString or similar
                                    val_str = str(value) if value is not None else None
                                    if val_str and ("key" in fname.lower() or "name" in fname.lower()):
                                        subreports.add(val_str)

            # Walk through field_data structure
            try:
                for classdesc_key, field_dict in x.field_data.items():
                    for field_obj, value in field_dict.items():
                        # field_obj is a JavaField with a 'name' attribute
                        fname = getattr(field_obj, "name", None)
                        if fname:
                            strings.add(fname)
                            fname_lower = fname.lower()

                            # Convert value to string (handles JavaString, regular str, etc.)
                            val_str = None
                            if value is not None:
                                if isinstance(value, str):
                                    val_str = value
                                elif hasattr(value, "__str__") and not hasattr(value, "field_data"):
                                    # It's a simple value type (JavaString, etc), not another JavaInstance
                                    try:
                                        val_str = str(value)
                                    except Exception:
                                        pass

                            if val_str:
                                if "param" in fname_lower and "parameter" in fname_lower:
                                    params.add(val_str)
                                if "field" in fname_lower and "name" in fname_lower:
                                    fields.add(val_str)
                                if ("variable" in fname_lower or "var" in fname_lower) and "name" in fname_lower:
                                    variables.add(val_str)

                        # Always walk the value
                        if value is not None:
                            walk(value, depth + 1)
            except Exception:
                pass
            return

        # handle javaobj.v2 JavaArray
        if hasattr(x, "__iter__") and hasattr(x, "__len__"):
            try:
                for item in x:
                    walk(item, depth + 1)
                return
            except Exception:
                pass

        # plain str
        if isinstance(x, str):
            strings.add(x)
            lx = x.lower()
            # heuristics: names of report, fields, params often short words
            # try to detect
            if len(x) < 200:
                if "report" in lx or "jasper" in lx or "jr" in lx or "field" in lx or "param" in lx or "subreport" in lx:
                    names.add(x)
            return

        # primitives: numbers, bools - ignore beyond adding reprs if interesting
        if isinstance(x, (int, float, bool)):
            return

        # fallback: inspect attributes for strings
        try:
            for attr in dir(x):
                if attr.startswith("_"):
                    continue
                try:
                    val = getattr(x, attr)
                except Exception:
                    continue
                if isinstance(val, str):
                    strings.add(val)
                    low = attr.lower()
                    if "name" in attr.lower() or "report" in attr.lower():
                        names.add(val)
                    if "param" in low or "parameter" in low:
                        params.add(val)
                else:
                    walk(val, depth + 1)
        except Exception:
            pass

    walk(obj, 0)

    return {
        "classes": sorted(classes),
        "strings": sorted(strings)[:200],  # limit size
        "names": sorted(names),
        "parameters": sorted(params),
        "fields": sorted(fields),
        "variables": sorted(variables),
        "subreports": sorted(subreports),
    }


def heuristics_scan_binary(data: bytes) -> Dict[str, Any]:
    """
    Fallback: scan extracted ASCII strings for typical tokens like 'parameter', 'field', 'subreport',
    and return candidate lists.
    """
    strings = extract_ascii_strings(data, min_len=4)
    found_params = set()
    found_fields = set()
    found_subreports = set()
    found_names = set()
    # use simple regex to find tokens with labels
    for s in strings:
        sl = s.lower()
        if "parameter" in sl or "param" in sl:
            found_params.add(s)
        if "field" in sl:
            found_fields.add(s)
        if "subreport" in sl:
            found_subreports.add(s)
        # candidate report name heuristics
        if "jasper" in sl or "report" in sl or s.endswith(".jrxml") or s.endswith(".jasper"):
            found_names.add(s)
    # also try to find things like "ParameterExpression" etc
    return {
        "strings_sample": strings[:200],
        "parameters": sorted(found_params),
        "fields": sorted(found_fields),
        "subreports": sorted(found_subreports),
        "names": sorted(found_names),
    }


def inspect_jasper_file(path: str, opts) -> Dict[str, Any]:
    """
    Inspect one .jasper file and return metadata dictionary.
    opts: namespace with flags (verbose, debug)
    """
    out = {"path": path, "errors": [], "warnings": []}
    try:
        with open(path, "rb") as f:
            data = f.read()
    except Exception as e:
        out["errors"].append(f"Failed to read file: {e}")
        return out

    out["size"] = len(data)
    out["has_java_serial_header"] = is_serialized_stream(data)
    # find classfile embeddings
    classfiles = find_classfiles(data)
    out["classfile_count"] = len(classfiles)
    out["classfiles"] = []
    major_versions = []
    for off, minor, major in classfiles:
        out["classfiles"].append({"offset": off, "minor": minor, "major": major, "java_version": MAJOR_TO_JAVA.get(major)})
        if isinstance(major, int):
            major_versions.append(major)
    out["highest_classfile_major"] = max(major_versions) if major_versions else None
    if out["highest_classfile_major"]:
        out["highest_java_version"] = MAJOR_TO_JAVA.get(out["highest_classfile_major"], "unknown")
    else:
        out["highest_java_version"] = None

    # Parse with javaobj
    parsed_root, warnings = safe_parse_with_javaobj(data)
    out["parse_warnings"] = warnings

    if parsed_root is not None:
        out["parsed"] = True
        try:
            collected = collect_from_parsed(parsed_root, max_depth=opts.max_depth)
            out.update(collected)
        except Exception as e:
            out["warnings"].append(f"Failed to collect from parsed object: {e}")
    else:
        out["parsed"] = False
        # fallback heuristics on binary
        out["heuristic"] = heuristics_scan_binary(data)

    # Basic counts
    out["counts"] = {
        "detected_classes": len(out.get("classes", [])),
        "detected_parameters": len(out.get("parameters", [])) if out.get("parameters") is not None else 0,
        "detected_fields": len(out.get("fields", [])) if out.get("fields") is not None else 0,
        "detected_subreports": len(out.get("subreports", [])) if out.get("subreports") is not None else 0,
    }
    return out


def format_summary(results: List[Dict[str, Any]]):
    rows = []
    for r in results:
        name_candidate = None
        if r.get("names"):
            name_candidate = r["names"][0]
        elif r.get("heuristic") and r["heuristic"].get("names"):
            name_candidate = r["heuristic"]["names"][0]
        rows.append(
            {
                "file": os.path.basename(r["path"]),
                "size": r.get("size", 0),
                "serial": "yes" if r.get("has_java_serial_header") else "no",
                "classfiles": r.get("classfile_count", 0),
                "highest_java": r.get("highest_java_version") or r.get("highest_classfile_major") or "-",
                "params": r["counts"].get("detected_parameters", 0),
                "fields": r["counts"].get("detected_fields", 0),
                "subreports": r["counts"].get("detected_subreports", 0),
                "name": name_candidate or "-",
            }
        )
    # pretty-print with tabulate if available
    if tabulate:
        table = tabulate(
            [
                [
                    row["file"],
                    row["size"],
                    row["serial"],
                    row["classfiles"],
                    row["highest_java"],
                    row["params"],
                    row["fields"],
                    row["subreports"],
                    row["name"],
                ]
                for row in rows
            ],
            headers=["file", "size", "serial", "classfiles", "java(ver)", "params", "fields", "subreports", "name"],
        )
        return table
    else:
        # simple textual
        lines = []
        header = "file\tsize\tserial\tclassfiles\tjava(ver)\tparams\tfields\tsubreports\tname"
        lines.append(header)
        for row in rows:
            lines.append(
                f"{row['file']}\t{row['size']}\t{row['serial']}\t{row['classfiles']}\t{row['highest_java']}\t{row['params']}\t{row['fields']}\t{row['subreports']}\t{row['name']}"
            )
        return "\n".join(lines)


def main(argv):
    ap = argparse.ArgumentParser(description="Inspect .jasper files for metadata useful to admins.")
    ap.add_argument("files", nargs="+", help=".jasper files to inspect")
    ap.add_argument("--json", action="store_true", help="Emit detailed JSON output instead of pretty text")
    ap.add_argument("--detail", action="store_true", help="Show detailed view (parameters, fields, subreports)")
    ap.add_argument("--verbose", "-v", action="count", default=0, help="Increase verbosity")
    ap.add_argument("--debug", action="store_true", help="Debug (very verbose)")
    ap.add_argument("--max-depth", dest="max_depth", type=int, default=12, help="Max recursion depth when walking object graph")
    opts = ap.parse_args(argv)

    results = []
    for p in opts.files:
        if not os.path.exists(p):
            print(f"[ERROR] File not found: {p}", file=sys.stderr)
            continue
        print(f"[INFO] Inspecting {p} ...") if opts.verbose else None
        res = inspect_jasper_file(p, opts)
        results.append(res)

    # Output
    if opts.json or opts.detail:
        # detailed JSON per file
        if opts.json:
            print(json.dumps(results, indent=2, ensure_ascii=False))
        else:
            # pretty detailed
            for r in results:
                print("=" * 80)
                print(f"File: {r['path']}")
                print(f"Size: {r.get('size', 0)} bytes")
                print(f"Java serialization header: {'present' if r.get('has_java_serial_header') else 'absent'}")
                print(f"Embedded class files: {r.get('classfile_count', 0)}")
                print(f"Highest classfile Java version: {r.get('highest_java_version') or r.get('highest_classfile_major')}")
                print()
                if r.get("parsed"):
                    print("Detected Java classes (sample):")
                    for cls in r.get("classes", [])[:30]:
                        print("  -", cls)
                    print()
                    print("Detected names / candidates:")
                    for nm in r.get("names", [])[:20]:
                        print("  -", nm)
                    print()
                    print("Parameters:")
                    for p in r.get("parameters", [])[:200]:
                        print("  -", p)
                    print()
                    print("Fields:")
                    for f in r.get("fields", [])[:200]:
                        print("  -", f)
                    print()
                    print("Subreports:")
                    for s in r.get("subreports", [])[:200]:
                        print("  -", s)
                else:
                    print("Could not parse with javaobj. Heuristic scan results:")
                    for k, v in r.get("heuristic", {}).items():
                        if isinstance(v, list):
                            print(f"{k} (sample {len(v)}):")
                            for it in v[:50]:
                                print("  -", it)
                        else:
                            print(f"{k}: {v}")
                if r.get("errors"):
                    print()
                    print("Errors:")
                    for e in r["errors"]:
                        print("  -", e)
                if r.get("parse_warnings"):
                    print()
                    print("Parse warnings:")
                    for w in r["parse_warnings"]:
                        print("  -", w)
                print()
    else:
        # concise summary table
        print(format_summary(results))


if __name__ == "__main__":
    main(sys.argv[1:])
