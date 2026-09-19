#!/usr/bin/env python3
"""Frontmatter tool for OKF artefacts. Stdlib only; flat keys plus the
`verified` list. Never hand-edit frontmatter — use this.

  fm.py get   FILE KEY
  fm.py set   FILE KEY VALUE          # creates the key if missing
  fm.py has   FILE KEY                # exit 0/1
  fm.py check FILE                    # OKF conformance: parseable, has type
  fm.py verify FILE ACTOR [ISO_TIME]  # append a verified entry
"""
import re, sys, datetime, pathlib

FENCE = "---"


def split(text):
    lines = text.split("\n")
    if not lines or lines[0].strip() != FENCE:
        return None, None
    for i in range(1, len(lines)):
        if lines[i].strip() == FENCE:
            return lines[1:i], lines[i + 1:]
    return None, None


def join(fm, body):
    return "\n".join([FENCE, *fm, FENCE, *body])


def find_key(fm, key):
    pat = re.compile(rf"^{re.escape(key)}:")
    for i, l in enumerate(fm):
        if pat.match(l):
            return i
    return -1


def block_end(fm, start):
    """End (exclusive) of a top-level key's block: next line that is neither
    indented nor blank."""
    j = start + 1
    while j < len(fm) and (fm[j].startswith(" ") or fm[j].strip() == ""):
        j += 1
    return j


def scalar(raw):
    """Value of a flat scalar key: quoted string, or bare value with any
    trailing ` # comment` removed."""
    v = raw.strip()
    if v[:1] in ('"', "'"):
        q = v[0]
        end = v.find(q, 1)
        return v[1:end] if end > 0 else v[1:]
    if " #" in v:
        v = v.split(" #", 1)[0]
    return v.strip()


def cmd_get(fm, key):
    i = find_key(fm, key)
    if i < 0:
        return 1
    print(scalar(fm[i].split(":", 1)[1]))
    return 0


def cmd_set(fm, key, value):
    i = find_key(fm, key)
    line = f"{key}: {value}"
    if i < 0:
        fm.append(line)
    else:
        end = block_end(fm, i)
        fm[i:end] = [line]
    return fm


def cmd_verify(fm, actor, when):
    entry = [f"  - by: {actor}", f"    at: {when}"]
    i = find_key(fm, "verified")
    if i < 0:
        fm += ["verified:"] + entry
        return fm
    val = fm[i].split(":", 1)[1].strip()
    if val in ("[]", "~"):            # empty list -> start one
        end = block_end(fm, i)
        fm[i:end] = ["verified:"] + entry
        return fm
    # val == "" means an existing block list: append to it
    end = block_end(fm, i)
    fm[end:end] = entry
    return fm


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    cmd, path = argv[1], pathlib.Path(argv[2])
    if not path.exists():
        print(f"error: {path} does not exist", file=sys.stderr)
        return 1
    text = path.read_text(encoding="utf-8")
    fm, body = split(text)

    if cmd == "check":
        if fm is None:
            print(f"FAIL {path}: no frontmatter")
            return 1
        i = find_key(fm, "type")
        if i < 0 or not fm[i].split(":", 1)[1].strip():
            print(f"FAIL {path}: no type")
            return 1
        print(f"ok   {path}")
        return 0

    if fm is None:
        print(f"error: {path} has no frontmatter", file=sys.stderr)
        return 1

    if cmd == "get":
        return cmd_get(fm, argv[3])
    if cmd == "has":
        return 0 if find_key(fm, argv[3]) >= 0 else 1
    if cmd == "set":
        fm = cmd_set(fm, argv[3], argv[4])
    elif cmd == "verify":
        when = argv[4] if len(argv) > 4 else datetime.datetime.now(
            datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        fm = cmd_verify(fm, argv[3], when)
    else:
        print(f"unknown command {cmd}", file=sys.stderr)
        return 2

    path.write_text(join(fm, body), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
