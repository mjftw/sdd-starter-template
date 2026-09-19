#!/usr/bin/env bash
# Enforce the context map: code under one context's root may import another
# context only through that context's published interface.
#
# Reads docs/domain.md › Contexts table for (name, code root). A published
# interface is anything under <root>/published/ (or <root>/api/, <root>/events/).
# Everything else under a root is internal to that context.
#
# Language-agnostic heuristic: any line matching an import/require/use/from
# that names another context's root and is not under a published path.
# Tune PUBLISHED and IMPORT_RE in the first /sdd-plan if the stack differs.
#
#   ./scripts/check-contexts.sh            # exit 1 on violations
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

[[ -f docs/domain.md ]] || { echo "no docs/domain.md — nothing to check"; exit 0; }

PUBLISHED='(published|api|events)'
IMPORT_RE='^[[:space:]]*(import|from|require|use|using|include)[[:space:](]'

# name<TAB>root from the Contexts table (skip header/separator rows)
mapfile -t CTX < <(awk -F'|' '
  /^## Contexts/ {p=1; next}
  p && /^## / {exit}
  p && NF>6 && $2 !~ /Context|---/ {
    gsub(/[` ]/,"",$2); gsub(/[` ]/,"",$6); if ($2!="" && $6!="") print $2 "\t" $6
  }' docs/domain.md)

[[ ${#CTX[@]} -eq 0 ]] && { echo "no contexts declared in docs/domain.md"; exit 0; }

FAIL=0
for entry in "${CTX[@]}"; do
  name="${entry%%	*}"; root="${entry##*	}"; root="${root%/}"
  [[ -d "$root" ]] || continue
  for other in "${CTX[@]}"; do
    oname="${other%%	*}"; oroot="${other##*	}"; oroot="${oroot%/}"
    [[ "$oname" == "$name" ]] && continue
    # imports of the other context that do not go through its published path
    hits=$(grep -rnE "$IMPORT_RE" "$root" 2>/dev/null \
           | grep -E "$oroot|[[:space:].]$oname[[:space:]./]" \
           | grep -vE "$oroot/$PUBLISHED|$oname\.$PUBLISHED" || true)
    if [[ -n "$hits" ]]; then
      echo "❌ $name reaches into $oname's internals:"
      echo "$hits" | sed 's/^/     /'
      FAIL=1
    fi
  done
done

[[ $FAIL -eq 0 ]] && echo "✅ context boundaries respected"
exit $FAIL
