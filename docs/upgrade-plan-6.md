---
type: Guide
title: Upgrade plan 6 — interface design
description: Change plan adding design to the ladder — principles at init, a "do we have a design?" decision tree and wireframes before each proposal, tokens at the first plan, a gate-free refinement loop on the live build with an exit, and a design-fidelity review pass — so agent-built products stop being correct and unstyled.
resource: /docs/upgrade-plan-6.md
status: draft
tags: [sdd, plan, upgrade]
---

# sdd-starter — upgrade plan part 6: interface design

**Executor:** a cheaper model. This plan is different in one way from parts
1–5: every file in it was built, run and looked at before the plan was
written, and the complete change ships beside this file as
`docs/upgrade-plan-6.patch`. Your job is to apply it, verify it with the
walk in Part 4, fix nothing you were not asked to, and delete both files in
the final task. If a step in the walk does not produce what it says, stop
and report; do not improvise.

**Baseline:** `main` after the merge of the `005-living-specs` pull request
("living specs and changes"). All paths are relative to the repo root.

---

## Part 1 — Why

A change built with parts 1–5 arrives functionally correct, covered by
scenarios, inside its bounded context, and unstyled. Nothing in the ladder
ever asked what the interface should look like, because every artefact is
words, and the first time anyone sees a screen is after the implementer has
already built it. In a product team a designer is in the room at three
moments: early, sketching what a feature is before the requirements are
fixed; at the start of the build, handing over a system of tokens and
components; and after the build, iterating on the real thing until it feels
right. This plan puts the agent in the room at the same three moments, and
adds the fourth thing a team has that we lacked: a record of what was tried,
so a decision made on the fifth attempt is not undone on the sixth.

The shape had to satisfy two constraints that pull against each other. The
ladder is built on gates, and gates are for commitments; design is
exploration, most of which is thrown away, and forcing it through approvals
would reproduce the "define everything up front" problem with pictures. And
with an agent, building the real screen costs about what a mockup costs, so
the prototype can be the product: the loop runs on the live app, not on a
mockup, and the mockup's only remaining job is structure.

### Design decisions (already made — do not re-decide)

- **`docs/design.md` is the design counterpart of `docs/engineering.md`**,
  type `Design Principles`, owned by the new `sdd-design` skill,
  hook-protected with `.sdd/unlock-design`. Two halves: **principles**
  (§1–§6: is there an interface, situations of use, tone, density,
  conventions, accessibility floor) gathered at `sdd-init` step 3b with no
  technology in them; **system** (§7–§9: approach, tokens, patterns) filled
  at the first `sdd-plan` that touches a screen. Plus a `Taste` section
  seeded from `~/.config/sdd/design-taste.md` if it exists, a `Screens`
  index of shipped screens with reference screenshots, and a refinement log.
- **"No interface" is decided once.** `sdd_interface: yes | no | unknown`
  in the frontmatter. `no` short-circuits every design step in every later
  change. `unknown` (a project initialised before this plan) is resolved by
  the first change that adds a screen.
- **Design runs per change, before the proposal**, as `sdd-design` entry
  point B, called from `sdd-specify`: does this change touch a screen? Do
  you already have a design (import it), will you make one elsewhere (the
  change pauses with a note saying what to bring back), or should the agent
  wireframe it? Then the walkthrough: every scenario stepped across the
  screens, producing the scenarios with no screen and the screen elements
  with no requirement, settled before the deltas are written. Its output is
  the proposal's new `## Interface` table (screen, state, route, design
  file, requirements seen here) and the files in `changes/<id>/design/`.
- **Wireframes are grey and structural.** `templates/wireframe.css` is
  deliberately ugly; `templates/wireframe-template.html` holds one
  `data-state` block per state, selected by `?state=`. The agent screenshots
  its wireframes with `scripts/design_snapshot.py … wireframes` and looks at
  them before the user does. A wireframe is a spec, never a source: nothing
  is copied from it into the app.
- **External tools are first-class, not required.** Claude Design or Figma
  for the divergent "show me four ways this could work" phase; the result
  is imported into `design/` and the repo does not care where it came from.
- **Tokens arrive with the stack.** `sdd-design` entry point C runs inside
  the first `sdd-plan` that has screens, after the stack is chosen, and is
  approved with that plan. `scripts/check-design.sh` then warns about
  hard-coded colours, sizes and fonts outside the tokens file, the way
  `check-contexts.sh` warns about imports.
- **The refinement loop has no gates.** `sdd-design` entry point D, after
  every task is done and before converge: the dev server runs, the user
  looks at the real device, says what is wrong; the agent implements up to
  three treatments behind a temporary `?variant=` switch, screenshots all
  of them in one command (`design_snapshot.py … live --variants a,b,c`), the
  user chooses; the round is recorded in `changes/<id>/design/rounds.md`
  (type `Design Log`) and committed. A round that changes behaviour writes
  the delta, out loud. The loop's **exit** is the commitment: reference
  screenshots into `design/reference/`, winning values promoted to
  `docs/design.md` §8–§9 (gated), `rounds.md` set to `exited`.
- **A `--design` change** (`new-change.sh <slug> --design`) is for shipped
  screens that feel wrong: intent, then the loop straight on the live app,
  no plan or tasks; `sdd_kind: design` on the proposal routes it.
- **Review pass 3c, design fidelity**, run by the `reviewer` (strongest
  model, multimodal): each Interface row's live screenshot against its
  reference, tokens only, and screens the change did *not* list unchanged
  against `docs/design/screens/` (visual scope creep is critical). A loop
  that has not exited is critical. No server means the pass is reported as
  not run, never as passed.
- **`sdd-finish` records the screens**: references copied to
  `docs/design/screens/`, rows proposed for `docs/design.md › Screens`,
  gated.
- **The design log is `rounds.md`, not `log.md`**: `log.md` is reserved by
  OKF and blocked by the hook.
- Model: all four entry points run on the strongest model in the main
  session. The implementer builds screens from tasks; it never designs them.

## Part 2 — Target layout

```
docs/
  design.md                          NEW  type: Design Principles (principles / system / screens / log)
  design/screens/<screen>--<state>.png   shipped references, copied at finish
changes/NNN-slug/
  proposal.md                        + ## Interface table
  design/
    rounds.md                        NEW  type: Design Log — origin, rounds, exit
    <screen>.html + wireframe.css    wireframes (or imported files of any kind)
    reference/<screen>--<state>.png  the loop's exit
.sdd/design/NNN-slug/{wireframes,live}/   ephemeral screenshots
scripts/
  check-design.sh                    NEW  standing + --change checks
  design_snapshot.py                 NEW  wireframes | live [--variants] | reference
  new-change.sh                      seeds design/rounds.md; --design flag
  init.sh                            seeds docs/design.md; copies taste master
  check-specs.sh                     Design section; check-design per change
  hooks/guard-paths.sh               docs/design.md needs .sdd/unlock-design
templates/
  design-template.md  rounds-template.md  wireframe.css  wireframe-template.html   NEW
  proposal-template.md               + ## Interface
  tasks-template.md                  + screen Verify line
.claude/
  skills/sdd-design/SKILL.md         NEW  entry points A (init) B (before proposal) C (first plan) D (loop + exit)
  skills/{sdd,sdd-init,sdd-specify,sdd-plan,sdd-tasks,sdd-implement,sdd-converge,sdd-finish}   edited
  agents/reviewer.md                 step 4b fidelity
  settings.json                      allow Write/Edit(changes/**), design_snapshot.py
REVIEW.md                            pass 3c
AGENTS.md  docs/okf.md  docs/sdd-guide.md  README.md                        edited
```

---

## Part 3 — Tasks

### Phase V — Apply

- [ ] **T501** · Confirm the baseline: `git status` clean; on branch
  `006-design` (it exists already with only this plan and its patch on it;
  if not, `git checkout -b 006-design main`);
  `test -f scripts/merge_delta.py && test -f templates/proposal-template.md`.

- [ ] **T502** · Apply the change:
  ```bash
  git apply --index --3way docs/upgrade-plan-6.patch
  git status --short | wc -l     # 28
  ```
  If `git apply` reports a conflict, stop and report which file. Do not
  hand-merge.
  — verify: `test -f .claude/skills/sdd-design/SKILL.md && test -x scripts/check-design.sh && test -x scripts/design_snapshot.py`

- [ ] **T503** · Syntax and OKF:
  ```bash
  bash -n scripts/*.sh scripts/hooks/*.sh && python3 -m py_compile scripts/design_snapshot.py
  for f in $(find docs templates .claude memory -name '*.md' ! -name index.md ! -name log.md ! -name README-project.md); do ./scripts/fm.py check "$f" >/dev/null || echo "FAIL $f"; done
  grep -c '—\|–' README.md docs/sdd-guide.md      # 0 and 0
  ```

- [ ] **T504** · Commit: `feat(sdd): interface design — principles, wireframes, tokens, refinement loop, fidelity pass`.

### Phase W — Verify (Part 4), then finish

- [ ] **T505** · Run the walk in Part 4 in a scratch copy. Every line marked
  `→` must produce what it says.
- [ ] **T506** · `git rm docs/upgrade-plan-6.md docs/upgrade-plan-6.patch`;
  also add `docs/upgrade-plan-6.md docs/upgrade-plan-6.patch` to the
  `rm -f` line in `scripts/init.sh` that removes the template's own plans.
  Commit `chore(sdd): v6 — interface design, verified`.
- [ ] **T507** · Report: the branch name, the commit list, and the walk's
  output. The user pushes and opens the pull request.

---

## Part 4 — The walk

Needs Playwright for Python (`pip install playwright && playwright install
chromium`; in the user's environment it may already be present). Run in a
scratch copy so the repo stays clean.

```bash
rm -rf /tmp/w6 && cp -r . /tmp/w6 && cd /tmp/w6 && rm -rf .git && git init -q -b main
mkdir -p ~/.config/sdd && printf -- '- likes: quiet type\n- hates: gradients\n' > ~/.config/sdd/design-taste.md
./scripts/init.sh "Demo" "A demo"
#   → prints "design taste: copied from …/design-taste.md"
./scripts/fm.py get docs/design.md sdd_interface            # → unknown
grep -c 'gradients' docs/design.md                          # → 1
./scripts/check-design.sh                                   # → ⚠️  … has not said whether there is an interface
./scripts/fm.py set docs/design.md sdd_interface no
./scripts/check-design.sh; echo $?                          # → ✅ no interface … skipped ; 0
./scripts/fm.py set docs/design.md sdd_interface yes

./scripts/new-change.sh the-circle                          # → lists delta, design, …
ls changes/001-the-circle/design                            # → rounds.md
./scripts/check-design.sh --change changes/001-the-circle   # → · Interface table still the template (proposal in draft)

# a wireframe and an Interface table with two deliberate faults
cd changes/001-the-circle
cp ../../templates/wireframe.css design/
sed -e 's/<screen name>/Circle/g' -e 's/<state-1>/idle/' -e 's/<state-2>/selected/' ../../templates/wireframe-template.html > design/circle.html
python3 - <<'EOF'
import pathlib
p=pathlib.Path('proposal.md'); s=p.read_text()
s=s.replace("| `<screen>` | `<state>` | | `design/<screen>.html?state=<state>` | `<context>.<capability>/REQ-001` |",
"| `circle` | `idle` | `/` | `design/circle.html?state=idle` | `theory.circle-of-fifths/REQ-001` |\n"
"| `circle` | `selected` | `/?key=G` | `design/circle.html?state=selected` | `theory.circle-of-fifths/REQ-002` |\n"
"| `circle` | `names-off` | `/?key=G&names=0` | `design/circle.html?state=names-off` | `theory.circle-of-fifths/REQ-009` |")
p.write_text(s)
EOF
mkdir -p delta/theory && printf -- '---\ntype: Spec Delta\nsdd_id: 001-the-circle\nsdd_context: theory\nsdd_capability: circle-of-fifths\n---\n## ADDED\n### REQ-001: Show the circle\nTHE SYSTEM SHALL show\n**Scenarios**\n- **REQ-001/S1 — shows**\n  Given a\n  When b\n  Then c\n### REQ-002: Select a key\nWHEN a key is chosen THE SYSTEM SHALL show its scale\n**Scenarios**\n- **REQ-002/S1 — g major**\n  Given a\n  When b\n  Then c\n' > delta/theory/circle-of-fifths.md
cd ../..
./scripts/check-design.sh --change changes/001-the-circle; echo $?
#   → ❌ circle · names-off: design/circle.html has no data-state="names-off"
#   → ❌ circle · names-off: cites theory.circle-of-fifths/REQ-009 which is not in the target state
#   → 1

# fix both
sed -i 's|REQ-009|REQ-002|' changes/001-the-circle/proposal.md
python3 - <<'EOF'
import pathlib
p=pathlib.Path('changes/001-the-circle/design/circle.html'); s=p.read_text()
p.write_text(s.replace('  <script>','  <section data-state="names-off" class="wf-screen"><div class="wf-box">Circle · G major</div><div class="wf-box tall">stave, no note names</div></section>\n  <script>'))
EOF
./scripts/check-design.sh --change changes/001-the-circle; echo $?      # → ✅ design checks clean ; 0

python3 scripts/design_snapshot.py changes/001-the-circle wireframes
#   → three lines, .sdd/design/001-the-circle/wireframes/circle--{idle,selected,names-off}.png
#   OPEN circle--names-off.png (Read it): exactly ONE grey phone frame, header "Circle · G major",
#   one tall box. If three frames are stacked, wireframe.css is wrong — stop and report.

# a fake live app, a round with variants, and the exit
mkdir -p .sdd/fake && cat > .sdd/fake/index.html <<'EOF'
<!doctype html><html><body><script>var q=new URLSearchParams(location.search);
document.body.innerHTML='<h1>circle '+(q.get('key')||'idle')+' variant='+(q.get('variant')||'-')+'</h1>';</script></body></html>
EOF
(cd .sdd/fake && python3 -m http.server 8765 >/dev/null 2>&1 &); sleep 1
python3 scripts/design_snapshot.py changes/001-the-circle live --base http://localhost:8765 --variants a,b
ls .sdd/design/001-the-circle/live | wc -l                  # → 9
python3 scripts/design_snapshot.py changes/001-the-circle reference --base http://localhost:8765
ls changes/001-the-circle/design/reference                  # → circle--idle.png circle--names-off.png circle--selected.png
./scripts/fm.py set changes/001-the-circle/design/rounds.md sdd_phase exited
./scripts/fm.py set docs/design.md sdd_phase approved
mkdir -p src && printf ':root{--ink:#333}\n' > src/tokens.css && printf 'h1{color:#ff0000}\n' > src/app.css
./scripts/check-design.sh --change changes/001-the-circle; echo $?
#   → ⚠️  1 hard-coded value(s) outside src/tokens.css … ; ✅ design checks clean ; 0
rm changes/001-the-circle/design/reference/circle--idle.png
./scripts/check-design.sh --change changes/001-the-circle | tail -2
#   → ❌ circle · idle: loop exited but no changes/001-the-circle/design/reference/circle--idle.png
./scripts/check-specs.sh | grep -A1 'Interface — 001'       # → the same ❌ line, nested under 001-the-circle
pkill -f 'http.server 8765'                                 # prints "Terminated"; that is the fake server, not a failure

./scripts/new-change.sh polish-circle --design
ls changes/002-polish-circle                                # → delta design index.md intent.md notes.md proposal.md  (no plan, no tasks)
./scripts/fm.py get changes/002-polish-circle/proposal.md sdd_kind   # → design
./scripts/new-change.sh x --bogus; echo $?                  # → error: unknown flag --bogus ; 1
```

If every `→` held, the change is verified.

---

## Part 5 — What this does not do (deliberately)

- No image generation. HTML the agent can render, screenshot and edit
  beats a PNG it cannot.
- No hi-fi mockups before the plan; that would force technology early.
- No pixel-diffing in the fidelity pass. The reviewer judges structure and
  tokens by looking; pixel tools produce noise on every font-rendering
  difference.
- No mandatory design for every change: `none` in the Interface table is a
  normal answer, and a product that said "no interface" never sees any of
  this.
- No design master beyond taste. Principles are per product; only likes
  and hates travel between projects.
