#!/usr/bin/env bash
# Static hygiene check over the artefact tree. Not a substitute for
# /sdd-converge, which reads the code; this only lints the artefacts.
#
#   ./scripts/check-specs.sh
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
warn() { echo "  ⚠️  $1"; }
bad()  { echo "  ❌ $1"; FAIL=1; }

artefacts() {
  find docs specs memory -name '*.md' \
    ! -name index.md ! -name log.md 2>/dev/null | sort
}

echo "Constitution"
if grep -q "PLACEHOLDER" memory/constitution.md 2>/dev/null; then
  bad "memory/constitution.md still has PLACEHOLDER articles — run /sdd-constitution"
elif [[ "$(./scripts/fm.py get memory/constitution.md sdd_phase 2>/dev/null)" != "ratified" ]]; then
  warn "constitution is not ratified"
else
  echo "  ✅ ratified v$(./scripts/fm.py get memory/constitution.md sdd_version)"
fi

echo
echo "Engineering preferences"
if [[ ! -f docs/engineering.md ]]; then
  warn "docs/engineering.md missing — run /sdd-engineering before any plan"
elif [[ "$(./scripts/fm.py get docs/engineering.md sdd_phase 2>/dev/null)" != "approved" ]]; then
  warn "docs/engineering.md is not approved"
else
  echo "  ✅ approved v$(./scripts/fm.py get docs/engineering.md sdd_version 2>/dev/null)"
fi

echo
echo "Domain map"
if [[ ! -f docs/domain.md ]]; then
  warn "docs/domain.md missing — /sdd-init step 4"
elif [[ "$(./scripts/fm.py get docs/domain.md sdd_phase 2>/dev/null)" != "approved" ]]; then
  warn "docs/domain.md is not approved"
else
  nctx=$(awk -F'|' '/^## Contexts/{p=1;next} p&&/^## /{exit} p&&NF>6&&$2!~/Context|---/{n++} END{print n+0}' docs/domain.md)
  echo "  ✅ approved ($nctx contexts)"
fi

echo
echo "AGENTS.md"
if grep -q "FILL THIS IN" AGENTS.md 2>/dev/null; then
  warn "AGENTS.md Commands/Conventions/Architecture still unfilled"
else
  echo "  ✅ commands and conventions recorded"
fi

echo
echo "OKF conformance"
FAILS=0
for f in $(artefacts); do
  ./scripts/fm.py check "$f" >/dev/null 2>&1 || { bad "$f: no frontmatter or no type"; FAILS=$((FAILS+1)); }
done
[[ "$FAILS" -eq 0 ]] && echo "  ✅ every artefact has a type"
for f in $(artefacts); do
  st=$(./scripts/fm.py get "$f" status 2>/dev/null || echo "")
  ph=$(./scripts/fm.py get "$f" sdd_phase 2>/dev/null || echo "")
  case "$ph" in
    approved|ratified|resolved|implemented|complete|accepted)
      [[ "$st" == "stable" ]] || warn "$f: sdd_phase=$ph but status=$st — use scripts/approve.sh"
      grep -q 'by: human:' "$f" || warn "$f: $ph but no human verified entry" ;;
  esac
done
./scripts/index.sh >/dev/null 2>&1 || warn "index.sh failed"

echo
if ! compgen -G "specs/[0-9][0-9][0-9]-*" > /dev/null; then
  echo "No slices yet. ./scripts/new-feature.sh <slug>"
  exit $FAIL
fi

for d in specs/[0-9][0-9][0-9]-*/; do
  id=$(basename "$d")
  echo "$id"

  [[ -f "$d/spec.md" ]] || { bad "no spec.md"; continue; }

  status=$(./scripts/fm.py get "$d/spec.md" sdd_phase 2>/dev/null || echo "unset")
  echo "  spec phase: $status"

  # Written against the current constitution?
  CUR_CONST=$(./scripts/fm.py get memory/constitution.md sdd_version 2>/dev/null || echo "")
  SPEC_CONST=$(./scripts/fm.py get "$d/spec.md" sdd_constitution 2>/dev/null || echo "")
  if [[ -n "$CUR_CONST" && -n "$SPEC_CONST" && "$CUR_CONST" != "$SPEC_CONST" ]]; then
    warn "spec written against constitution $SPEC_CONST; current is $CUR_CONST — re-check compliance"
  fi

  # Intent present and resolved before the spec leaves draft?
  if [[ "$status" != "draft" && "$status" != "unset" ]]; then
    if [[ ! -f "$d/intent.md" ]]; then
      bad "no intent.md — the user's words were never recorded"
    elif [[ "$(./scripts/fm.py get "$d/intent.md" sdd_phase 2>/dev/null)" != "resolved" ]]; then
      warn "intent.md is not resolved but spec is $status"
    fi
  fi

  # On the roadmap?
  if [[ -f docs/roadmap.md ]] && ! grep -q "$id" docs/roadmap.md; then
    warn "$id is not listed in docs/roadmap.md"
  fi

  ctx=$(./scripts/fm.py get "$d/spec.md" sdd_context 2>/dev/null || echo "")
  if [[ -z "$ctx" || "$ctx" == "<context>" ]]; then
    [[ "$status" == "draft" ]] || warn "spec has no sdd_context"
  elif [[ -f docs/domain.md ]] && ! grep -qE "^\| *\`?$ctx\`? *\|" docs/domain.md; then
    bad "sdd_context '$ctx' is not a context in docs/domain.md"
  fi

  reqs=$(grep -cE '^### REQ-[0-9]+' "$d/spec.md" || true)
  if [[ "$reqs" -eq 0 ]]; then
    bad "spec.md has no REQ- requirements"
  else
    echo "  ✅ $reqs requirement(s)"
  fi

  # Unreplaced template scaffolding. An untouched spec is noise for the
  # coverage checks below, so skip them rather than emit findings per row.
  UNTOUCHED=false
  if grep -qE '<[A-Za-z][^>]*>|REQ-001: <short name>' "$d/spec.md"; then
    warn "spec.md still contains template placeholders — not yet written"
    UNTOUCHED=true
  fi

  # Weak modal verbs where SHALL belongs.
  if grep -nE '\b(should|must|will|may|can)\b' "$d/spec.md" \
     | grep -viE '^\s*[0-9]+:\s*(>|<!--)' | grep -qE 'SYSTEM'; then
    warn "spec.md mixes should/must/will/may into a SHALL statement"
  fi

  # Technology leaking into the spec.
  if grep -niE '\b(postgres|mysql|sqlite|redis|kafka|react|vue|svelte|django|flask|fastapi|express|docker|kubernetes|graphql|grpc)\b' \
     "$d/spec.md" | grep -qv '^\s*[0-9]*:\s*>'; then
    warn "spec.md names a technology — that belongs in plan.md"
  fi

  if $UNTOUCHED; then echo; continue; fi

  for r in $(grep -oE '^### REQ-[0-9]+' "$d/spec.md" | sed 's/### //'); do
    grep -qE "$r/S[0-9]+" "$d/spec.md" || warn "$r has no scenario"
  done

  # Open questions left in an approved spec.
  if [[ "$status" == "approved" ]]; then
    if awk '/^## Open questions/,/^## /' "$d/spec.md" \
       | grep -qE '^\| [0-9]+ \|[^|]*[A-Za-z]'; then
      warn "approved spec still lists open questions"
    fi
  fi

  # Requirement coverage and task anatomy in tasks.md.
  if [[ -f "$d/tasks.md" ]]; then
    for r in $(grep -oE 'REQ-[0-9]+' "$d/spec.md" | sort -u); do
      grep -q "$r" "$d/tasks.md" || bad "$r has no task in tasks.md"
    done
    for t in $(grep -oE '^### T[0-9]+' "$d/tasks.md" | sed 's/### //'); do
      blk=$(awk -v t="### $t " 'index($0,t)==1{p=1;print;next} p&&(/^### /||/^## /){exit} p{print}' "$d/tasks.md")
      for need in '\*\*Status:\*\*' '\*\*Files\*\*' '\*\*Steps\*\*' '\*\*Verify\*\*'; do
        printf '%s' "$blk" | grep -qE "$need" || warn "$t is missing $need"
      done
      if printf '%s' "$blk" | grep -qE 'TBD|TODO|handle (edge|error) |error handling|similar to T|like T[0-9]'; then
        warn "$t contains a placeholder phrase"
      fi
    done
  fi

  # Plan must map every requirement.
  if [[ -f "$d/plan.md" ]] && grep -q 'REQ-' "$d/plan.md"; then
    for r in $(grep -oE 'REQ-[0-9]+' "$d/spec.md" | sort -u); do
      grep -q "$r" "$d/plan.md" || warn "$r is not mapped in plan.md"
    done
  fi
  echo
done

if [[ $FAIL -eq 0 ]]; then
  echo "✅ artefact tree clean"
else
  echo "❌ problems found"
fi
exit $FAIL
