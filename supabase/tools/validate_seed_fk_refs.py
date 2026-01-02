#!/usr/bin/env python3
"""Validate that every referenced UUID in supabase/seed_converted.sql has
a corresponding primary-key insertion earlier in the file.

Usage: python3 supabase/tools/validate_seed_fk_refs.py
Exits with 0 when no missing refs found, non-zero otherwise.
"""
import re
import sys
from pathlib import Path

SEED_PATH = Path(__file__).resolve().parents[1] / "seed_converted.sql"

UUID_RE = re.compile(
    r"'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'", re.IGNORECASE
)
INSERT_RE = re.compile(
    r'INSERT\s+INTO\s+([\w\."]+)\s*\(([^)]+)\)\s*VALUES\s*(\(.+?\));',
    re.IGNORECASE | re.DOTALL,
)


def split_top_level_tuples(s: str):
    tuples = []
    i = 0
    n = len(s)
    while i < n:
        # find next '('
        while i < n and s[i] != "(":
            i += 1
        if i >= n:
            break
        depth = 0
        start = i
        while i < n:
            if s[i] == "(":
                depth += 1
            elif s[i] == ")":
                depth -= 1
                if depth == 0:
                    i += 1
                    break
            i += 1
        tuples.append(s[start:i])
        # skip comma/whitespace after tuple
        while i < n and s[i] in ",\n \t\r":
            i += 1
    return tuples


def split_values(tuple_str: str):
    # strip surrounding parentheses
    t = tuple_str.strip()
    if t.startswith("(") and t.endswith(")"):
        t = t[1:-1]
    vals = []
    cur = []
    in_squote = False
    escape = False
    for ch in t:
        if escape:
            cur.append(ch)
            escape = False
            continue
        if ch == "\\":
            escape = True
            cur.append(ch)
            continue
        if ch == "'":
            in_squote = not in_squote
            cur.append(ch)
            continue
        if ch == "," and not in_squote:
            vals.append("".join(cur).strip())
            cur = []
            continue
        cur.append(ch)
    if cur:
        vals.append("".join(cur).strip())
    return vals


def normalize_col(col: str):
    return col.strip().strip('"').strip()


def extract_uuids_from_values(vals):
    found = set()
    for v in vals:
        for m in UUID_RE.finditer(v):
            found.add(m.group(0).strip("'"))
    return found


def main():
    if not SEED_PATH.exists():
        print(f"Seed file not found: {SEED_PATH}")
        return 2

    text = SEED_PATH.read_text()

    seen_pks = set()
    missing = []
    insert_count = 0

    for m in INSERT_RE.finditer(text):
        insert_count += 1
        table = m.group(1).strip()
        cols_raw = m.group(2)
        vals_block = m.group(3)
        cols = [normalize_col(c) for c in cols_raw.split(",")]
        tuples = split_top_level_tuples(vals_block)
        for tup in tuples:
            vals = split_values(tup)
            # map col->val
            col_val = {
                cols[i]: vals[i] if i < len(vals) else "" for i in range(len(cols))
            }
            # find pk value: prefer columns named 'id' or ending with '_id' that contain a UUID
            pk = None
            for colname, val in col_val.items():
                lname = colname.lower()
                if lname == "id" or lname.endswith("_id") or lname.endswith("id"):
                    v = str(val).strip()
                    if v.startswith("'") and v.endswith("'"):
                        inner = v.strip("'")
                        if re.fullmatch(
                            r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
                            inner,
                            re.IGNORECASE,
                        ):
                            pk = inner
                            break
                    else:
                        if re.fullmatch(
                            r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
                            v,
                            re.IGNORECASE,
                        ):
                            pk = v
                            break
            # collect UUIDs referenced in this tuple (excluding the pk itself)
            uuids = extract_uuids_from_values(vals)
            if pk and pk in uuids:
                uuids.discard(pk)
            # check each referenced uuid was seen earlier
            for ref in sorted(uuids):
                if ref not in seen_pks:
                    missing.append((insert_count, table, ref, tup.strip()))
            # after checks, add pk(s) to seen_pks
            if pk:
                seen_pks.add(pk)

    if missing:
        print(f"Validation FAILED: found {len(missing)} forward/missing references:\n")
        for idx, table, ref, context in missing[:200]:
            print(
                f"Insert #{idx} into {table} references {ref} which was not inserted earlier. Context: {context[:200]}"
            )
        if len(missing) > 200:
            print(f"... and {len(missing)-200} more")
        return 1

    print(
        f"Validation passed. Scanned {insert_count} INSERT statements; no missing forward references found."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
