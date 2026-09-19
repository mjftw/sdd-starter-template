#!/usr/bin/env bash
# Allocate the next feature number, create specs/NNN-slug/, seed it from
# templates/, and optionally create a git branch.
#
#   ./scripts/new-feature.sh user-login
#   ./scripts/new-feature.sh user-login --branch
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SLUG="${1:-}"
MAKE_BRANCH=false
[[ "${2:-}" == "--branch" ]] && MAKE_BRANCH=true

if [[ -z "$SLUG" ]]; then
  echo "usage: $0 <kebab-case-slug> [--branch]" >&2
  echo "  slug describes the change, not the mechanism:" >&2
  echo "  good: user-login    bad: add-jwt-middleware" >&2
  exit 1
fi

if [[ ! "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: slug must be kebab-case (lowercase, hyphens): got '$SLUG'" >&2
  exit 1
fi

# Next number: highest existing NNN + 1, zero-padded to 3.
NEXT=1
if compgen -G "specs/[0-9][0-9][0-9]-*" > /dev/null; then
  HIGHEST=$(for d in specs/[0-9][0-9][0-9]-*/; do basename "$d"; done | sed 's/-.*//' | sort -n | tail -1)
  NEXT=$((10#$HIGHEST + 1))
fi
NNN=$(printf "%03d" "$NEXT")
DIR="specs/${NNN}-${SLUG}"

if [[ -d "$DIR" ]]; then
  echo "error: $DIR already exists" >&2
  exit 1
fi

mkdir -p "$DIR"
TODAY=$(date +%Y-%m-%d)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Constitution version, so the spec records what it was written against.
CONST_VER=$(./scripts/fm.py get memory/constitution.md sdd_version 2>/dev/null || echo "0.0.0")

for t in intent spec plan tasks; do
  sed -e "s|NNN-slug|${NNN}-${SLUG}|g" \
      -e "s|conversation:YYYY-MM-DD|conversation:${TODAY}|" \
      -e "s|at: YYYY-MM-DDTHH:MM:SSZ|at: ${NOW}|" \
      -e "s|^sdd_constitution: .*|sdd_constitution: ${CONST_VER}|" \
      "templates/${t}-template.md" > "${DIR}/${t}.md"
done

cat > "${DIR}/notes.md" <<EOF
---
type: Implementation Notes
title: ${NNN}-${SLUG} — notes
description: Decisions taken during implementation that the plan did not cover.
resource: /specs/${NNN}-${SLUG}/notes.md
status: draft
tags: [sdd, notes, "slice:${NNN}-${SLUG}"]
sdd_id: ${NNN}-${SLUG}
---

# Notes — ${NNN}-${SLUG}

Decisions taken during implementation that the plan did not cover, and why.
One line each, newest last.

EOF

./scripts/index.sh >/dev/null

echo "created $DIR"
ls -1 "$DIR" | sed 's/^/  /'

if $MAKE_BRANCH && git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH="${NNN}-${SLUG}"
  git checkout -b "$BRANCH"
  echo "on branch $BRANCH"
fi

echo
echo "next: fill ${DIR}/intent.md  (the user's words — grill writes it)"
