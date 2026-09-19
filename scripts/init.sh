#!/usr/bin/env bash
# One-time instantiation of a repository created from sdd-starter.
#   ./scripts/init.sh "Project Name" "One-line description"
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

NAME="${1:?usage: init.sh \"Project Name\" \"One-line description\"}"
DESC="${2:?usage: init.sh \"Project Name\" \"One-line description\"}"
TODAY=$(date +%Y-%m-%d)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if ! grep -q '<PROJECT NAME>' README.md; then
  echo "already initialised (README.md has no <PROJECT NAME> placeholder)" >&2
  exit 1
fi

# Seed the project-level docs from templates.
for t in product domain roadmap glossary; do
  sed -e "s|conversation:YYYY-MM-DD|conversation:${TODAY}|" \
      -e "s|at: YYYY-MM-DDTHH:MM:SSZ|at: ${NOW}|" \
      "templates/${t}-template.md" > "docs/${t}.md"
done

# Engineering preferences: copy the master if one exists; otherwise /sdd-init
# will interview for them.
MASTER="${SDD_ENGINEERING:-$HOME/.config/sdd/engineering.md}"
if [[ -f "$MASTER" ]]; then
  cp "$MASTER" docs/engineering.md
  echo "engineering preferences: copied from $MASTER"
else
  echo "engineering preferences: no master at $MASTER — /sdd-init will interview"
fi

# Fill the name and description where they appear.
mkdir -p .sdd && touch .sdd/unlock-index
for f in README.md docs/product.md index.md; do
  [[ -f "$f" ]] || continue
  sed -i -e "s|<PROJECT NAME>|${NAME}|g" -e "s|<ONE LINE>|${DESC}|g" "$f"
done
rm -f .sdd/unlock-index

# Remove the template's own upgrade plans if still present.
rm -f docs/upgrade-plan.md docs/upgrade-plan-2.md docs/upgrade-plan-3.md

./scripts/index.sh >/dev/null

# Git.
if [[ ! -d .git ]]; then git init -q -b main; fi
git add -A
git commit -q -m "chore: initialise ${NAME} from sdd-starter" || true

echo "initialised: ${NAME}"
echo "next: open your agent here and run /sdd-init"
