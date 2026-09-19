#!/usr/bin/env bash
# Pass a gate. Sets OKF status → stable, sdd_phase → PHASE, appends a
# human verified entry, appends to log.md. Run only after the user has
# approved in conversation.
#
#   ./scripts/approve.sh specs/001-slug/spec.md approved
#   ./scripts/approve.sh memory/constitution.md ratified
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
FILE="${1:?usage: approve.sh FILE PHASE [ACTOR]}"
PHASE="${2:?usage: approve.sh FILE PHASE [ACTOR]}"
ACTOR="${3:-}"
if [[ -z "$ACTOR" ]]; then
  NAME=$(git config user.name 2>/dev/null | tr 'A-Z ' 'a-z-' || true)
  ACTOR="human:${NAME:-user}"
fi
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

./scripts/fm.py set "$FILE" status stable
./scripts/fm.py set "$FILE" sdd_phase "$PHASE"
./scripts/fm.py verify "$FILE" "$ACTOR" "$NOW"

TYPE=$(./scripts/fm.py get "$FILE" type 2>/dev/null || echo "artefact")

SDD_LOG_FILE="$FILE" SDD_LOG_TYPE="$TYPE" SDD_LOG_PHASE="$PHASE" \
SDD_LOG_ACTOR="$ACTOR" SDD_LOG_DATE="${NOW%%T*}" python3 - <<'PY'
import os, pathlib
p = pathlib.Path("log.md")
head = "# Log\n\nChronological history of this bundle. Newest date first.\n"
if not p.exists():
    p.write_text(head, encoding="utf-8")
lines = p.read_text(encoding="utf-8").split("\n")
day = "## " + os.environ["SDD_LOG_DATE"]
entry = "- {} `{}` → {} ({})".format(
    os.environ["SDD_LOG_TYPE"], os.environ["SDD_LOG_FILE"],
    os.environ["SDD_LOG_PHASE"], os.environ["SDD_LOG_ACTOR"])
if day in lines:
    i = lines.index(day)
    j = i + 1
    while j < len(lines) and lines[j].strip() == "":
        j += 1
    lines[j:j] = [entry]                      # newest first within the day
else:
    i = 3                                      # after the intro paragraph
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    lines[i:i] = [day, "", entry, ""]
p.write_text("\n".join(lines), encoding="utf-8")
PY

echo "$FILE: status=stable sdd_phase=$PHASE verified by $ACTOR"
