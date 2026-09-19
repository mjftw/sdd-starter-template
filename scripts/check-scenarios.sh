#!/usr/bin/env bash
# Scenario coverage: every REQ in every non-draft spec has ≥1 scenario, and
# every scenario ID appears verbatim in a test file under tests/.
#
#   ./scripts/check-scenarios.sh                 # all slices
#   ./scripts/check-scenarios.sh specs/001-slug  # one slice
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
FAIL=0
TESTDIR="${SDD_TEST_DIR:-tests}"

slices=("$@"); [[ ${#slices[@]} -eq 0 ]] && slices=(specs/[0-9][0-9][0-9]-*/)
for d in "${slices[@]}"; do
  d="${d%/}"; [[ -f "$d/spec.md" ]] || continue
  phase=$(./scripts/fm.py get "$d/spec.md" sdd_phase 2>/dev/null || echo draft)
  echo "$(basename "$d") ($phase)"
  for r in $(grep -oE '^### REQ-[0-9]+' "$d/spec.md" | sed 's/### //' | sort -u); do
    scen=$(grep -oE "$r/S[0-9]+" "$d/spec.md" | sort -u)
    if [[ -z "$scen" ]]; then
      echo "  ❌ $r has no scenario"; FAIL=1; continue
    fi
    for s in $scen; do
      sid="${s//\//_}"                       # REQ-004/S2 -> REQ-004_S2 for identifiers
      if [[ -d "$TESTDIR" ]] && grep -rqE "$s|$sid|${sid//-/_}" "$TESTDIR" 2>/dev/null; then
        echo "  ✅ $s tested"
      elif [[ "$phase" == "draft" || "$phase" == "in-review" ]]; then
        echo "  · $s (spec not yet approved; no test expected)"
      else
        echo "  ❌ $s has no test citing it"; FAIL=1
      fi
    done
  done
done
[[ $FAIL -eq 0 ]] && echo "✅ scenario coverage complete" || echo "❌ scenario gaps"
exit $FAIL
