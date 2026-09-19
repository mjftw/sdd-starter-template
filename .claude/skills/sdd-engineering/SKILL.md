---
type: Skill
name: sdd-engineering
description: Establish, load, or refine the user's cross-project engineering preferences (paradigm, typing, errors, testing, architecture, tooling) — docs/engineering.md, mastered at ~/.config/sdd/engineering.md. Use during sdd-init, when docs/engineering.md is missing, when the user says "my coding preferences", "how I like code written", "engineering standards", or when a review surfaces a preference not yet recorded.
---

# Engineering preferences

These do not change per project. They change slowly, across projects, as the
user learns what they want. So: one master outside the repo, a copy inside,
and a discipline for keeping them in step.

## Resolve

1. If `docs/engineering.md` exists and `sdd_phase` is `approved` → **load it**.
   Say one line: "engineering preferences loaded, v<sdd_version>". Done.
2. Else look for the master, in order: `$SDD_ENGINEERING`,
   `~/.config/sdd/engineering.md`. If found → copy it to `docs/engineering.md`,
   say so, done. (`scripts/init.sh` does this too; this is the fallback.)
3. Else → **interview** (below), write both the repo copy and the master.

## Interview

**Run on the strongest model available.** One question per section of
`templates/engineering-template.md`, in order, **one at a time**, each with
the template's default offered as the recommendation — the user confirms,
changes, or replaces it. Their answer goes on the `**Mine:**` line in their
words; a bare "yes" records "as default".

Push where an answer is vague ("good types" → *which* strict mode, *which*
escape hatches are allowed). Accept "don't care" — record "no preference;
follow default" so it is never asked again.

Where the user's stated stack is known (from `docs/product.md` or the
conversation), tailor the tooling question to it — offer the community
standard per language rather than a blank table.

**Gate.** Show the completed file. `AskUserQuestion`: *Approve* / *Revise*.
On approval:

- `mkdir -p .sdd && touch .sdd/unlock-engineering`
- write `docs/engineering.md` (seeded from the template)
- `./scripts/fm.py set docs/engineering.md sdd_version 1.0.0`
- `./scripts/approve.sh docs/engineering.md approved`
- `rm -f .sdd/unlock-engineering`
- `./scripts/index.sh`
- ask once: "Write this as the master at `~/.config/sdd/engineering.md` so
  future projects start from it?" — on yes, `mkdir -p ~/.config/sdd` and copy
  it there
- append to `docs/decisions.md`:
  `<date> · engineering · preferences v1.0.0 ratified · <one line>`
- commit `docs(engineering): preferences v1.0.0`

## Refine

Triggered by the user, or by `sdd-converge` pass 8 when a `notes.md` line or a
recurring review finding reveals a preference that is not written down.

1. State the proposed change: section, old line, new line, and the evidence
   (which finding, which project).
2. **Gate.** *Apply* / *Reject* / *Reword*.
3. On apply: `mkdir -p .sdd && touch .sdd/unlock-engineering`, edit
   `docs/engineering.md`, bump `sdd_version` with `./scripts/fm.py set`
   (PATCH for wording, MINOR for a new preference, MAJOR for reversing one),
   append to the refinement log, `rm -f .sdd/unlock-engineering`.
4. Ask once: "Sync to master?" — on yes, copy `docs/engineering.md` over the
   master. Never sync without asking; the master affects every future project.

## Rules

- The unlock file exists only between approval and commit.
- The spec (`spec.md`) never reads this file and never cites it. Preferences
  are how, not what.
- The plan cites it: any plan choice that departs from a preference names the
  section and the reason, as an open question for the user.
- Agents never edit this file outside this skill. The `guard-paths` hook
  blocks it.
- A preference the user has recorded is not re-litigated by an agent. Say
  once that you would do otherwise and why; then follow it. Article I.
