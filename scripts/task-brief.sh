#!/usr/bin/env bash
# Build the self-contained brief for one task, so the implementer never reads
# the whole plan and the controller never pastes exact values by hand.
#
#   ./scripts/task-brief.sh specs/001-slug T011
#   → .sdd/briefs/001-slug/T011.md   (path printed)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

SLICE="${1:?usage: task-brief.sh specs/NNN-slug T0NN}"
SLICE="${SLICE%/}"
TID="${2:?usage: task-brief.sh specs/NNN-slug T0NN}"
NAME=$(basename "$SLICE")
OUT=".sdd/briefs/${NAME}/${TID}.md"
mkdir -p "$(dirname "$OUT")"

# Section extractor: from a "### <prefix>" heading to the next "### " or "## ".
section() { # file prefix
  awk -v t="$2" '
    index($0, t) == 1 { p = 1; print; next }
    p && (/^### / || /^## /) { exit }
    p { print }' "$1"
}
h2() { # file "## Heading"
  awk -v t="$2" '
    index($0, t) == 1 { p = 1; print; next }
    p && /^## / { exit }
    p { print }' "$1"
}

TASK=$(section "$SLICE/tasks.md" "### $TID ")
if [[ -z "$TASK" ]]; then
  echo "error: no task '$TID' in $SLICE/tasks.md" >&2; exit 1
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
STALE=$(date -u -d '+7 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+7d +%Y-%m-%dT%H:%M:%SZ)

{
  echo "---"
  echo "type: Task Brief"
  echo "title: Brief — $TID · $NAME"
  echo "description: Everything needed to implement $TID, and nothing else."
  echo "resource: /$OUT"
  echo "status: draft"
  echo "tags: [sdd, brief, \"slice:$NAME\"]"
  echo "sources:"
  echo "  - resource: /$SLICE/tasks.md"
  echo "  - resource: /$SLICE/spec.md"
  echo "  - resource: /$SLICE/plan.md"
  echo "  - resource: /docs/engineering.md"
  echo "generated:"
  echo "  by: process:task-brief.sh"
  echo "  at: $NOW"
  echo "stale_after: $STALE"
  echo "sdd_id: $NAME"
  echo "---"
  echo
  echo "# Brief — $TID · $NAME"
  echo
  echo "You have this brief and nothing else. Exact values below are the"
  echo "requirements; use them verbatim. If something you need is missing,"
  echo "report NEEDS_CONTEXT with the exact question. Do not guess."
  echo
  echo "## Task (verbatim from tasks.md)"; echo
  printf '%s\n' "$TASK"
  echo
  echo "## Requirements cited (verbatim from spec.md)"
  for r in $(printf '%s\n' "$TASK" | head -1 | grep -oE 'REQ-[0-9]+' | sort -u); do
    echo; section "$SLICE/spec.md" "### $r"
  done
  echo
  echo "## From plan.md"
  for h in "## Interfaces" "## Data model" "## Structure" "## Test strategy"; do
    echo; h2 "$SLICE/plan.md" "$h"
  done
  echo
  echo "## Engineering preferences (docs/engineering.md)"; echo
  if [[ -f docs/engineering.md ]]; then cat docs/engineering.md; else echo "_none recorded_"; fi
  echo
  echo "## Commands (AGENTS.md)"; echo
  h2 AGENTS.md "## Commands"
  echo
  echo "## Constitution"; echo
  cat memory/constitution.md
} > "$OUT"

echo "$OUT"
