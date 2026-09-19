#!/usr/bin/env bash
# Regenerate OKF index.md files from frontmatter. Idempotent. Run after any
# gate; check-specs.sh warns when an index is stale.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

row() { # file relpath
  local f="$1" rel="$2" t ty ph d
  t=$(./scripts/fm.py get "$f" title 2>/dev/null || basename "$f" .md)
  ty=$(./scripts/fm.py get "$f" type 2>/dev/null || echo "")
  ph=$(./scripts/fm.py get "$f" sdd_phase 2>/dev/null || echo "")
  d=$(./scripts/fm.py get "$f" description 2>/dev/null || echo "")
  printf -- '- [%s](%s) — %s%s%s\n' "$t" "$rel" "$ty" "${ph:+ · $ph}" "${d:+ — $d}"
}

gen() { # dir title
  local dir="$1" title="$2" out="$1/index.md" f sub
  {
    echo "# $title"
    echo
    for f in "$dir"/*.md; do
      [[ -e "$f" ]] || continue
      case "$(basename "$f")" in index.md|log.md) continue ;; esac
      row "$f" "$(basename "$f")"
    done
    for sub in "$dir"/*/; do
      [[ -d "$sub" && -f "${sub}index.md" ]] || continue
      printf -- '- [%s/](%s/index.md)\n' "$(basename "$sub")" "$(basename "$sub")"
    done
  } > "$out"
  echo "wrote $out"
}

for s in specs/[0-9][0-9][0-9]-*/; do
  [[ -d "$s" ]] && gen "${s%/}" "Slice $(basename "$s")"
done
[[ -d docs/adr ]] && gen docs/adr "Architecture Decision Records"
gen docs "Project documents"
gen specs "Slices"
