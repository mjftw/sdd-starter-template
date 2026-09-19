---
type: Guide
title: Upgrade plan 5 — living specs and changes
description: Change plan splitting the current truth (specs/ by capability) from proposals (changes/ with delta specs), so the product can evolve without its specs contradicting each other.
resource: /docs/upgrade-plan-5.md
status: draft
tags: [sdd, plan, upgrade]
---

# sdd-starter — upgrade plan part 5: living specs and changes

**Executor:** a cheaper model. Every task is mechanical: file, exact content or
exact edit, verify line. If a task is ambiguous, stop and ask. Work in the
repository root. Commit after each phase with the message given. Delete this
file in the final task.

**Baseline:** `main` at the commit `fix(init): no technology questions until
the first plan`. All paths below are relative to the repo root.

**Every script and template in this plan was built and tested end to end
before the plan was written** (a two-change scenario: create a capability,
then modify, remove and add against it; preview isolation; re-apply refusal;
coverage of removed requirements; archive-aware numbering). Reproduce them
exactly; do not improve them.

---

## Part 1 — Why

The current layout, `specs/NNN-slug/`, one directory per slice in build order,
describes a *sequence of changes*. It has no document that says what the
system does *now*. After slice 005 changes a rule that slice 001 set, both
specs are "implemented" and they contradict each other; the truth is only
reconstructible by reading both and knowing which won. `check-scenarios.sh`
still demands a test for 001's superseded scenario. There is no mechanism for
a change to *modify* an approved requirement, only a rule against editing
approved specs. This is Spec Kit's shape, chosen for a greenfield start; every
project is greenfield for exactly one slice.

OpenSpec's model separates the two: `specs/` holds the current truth and
`changes/` holds proposals with **delta specs** that are merged into the truth
when they ship. This plan adopts that split and organises the truth by bounded
context and capability (the DDD layer from part 4), so "what does the system
do" is answered by one living document per capability.

### Design decisions (already made — do not re-decide)

- **`specs/<context>/<capability>.md` is the current truth.** One living
  Capability Spec per capability, organised by bounded context. Every
  requirement in it is true of the system now. It is **never hand-edited**:
  the `guard-paths` hook blocks the edit tools on `specs/**`, and the only
  writer is `scripts/merge_delta.py`.
- **`changes/NNN-slug/` is a proposal.** intent → proposal → delta → plan →
  tasks → notes. `proposal.md` is the old `spec.md` with its Requirements
  section replaced by a list of the deltas. Requirements live only in delta
  files.
- **A delta is ADDED / MODIFIED / REMOVED against the living spec.** ADDED
  takes the next free ID; MODIFIED gives the full new block plus a `**Was:**`
  quote; REMOVED gives the reason. `merge_delta.py` refuses an ADDED that
  exists, a MODIFIED or REMOVED that does not, and a REMOVED that already was.
- **Merge happens at `sdd-finish`, after converge.** `merge_delta.py apply`
  writes into `specs/`, bumps the capability's `sdd_version` (MINOR for
  added/modified, MAJOR if anything removed), appends the change's proposal to
  its `sources`, adds a History row, then the change directory moves to
  `changes/archive/`. Removed requirements stay in the living spec struck
  through with the change that removed them. IDs are never reused.
- **Before merge, everything works on the target state.** `merge_delta.py
  preview` writes the merged result to `.sdd/target/<change>/` without
  touching `specs/`. `task-brief.sh`, `task-reviewer`, `reviewer` and
  `check-scenarios.sh --change` all read the target, so the implementer sees
  what the capability must do *after* the change, not the delta alone.
- **Requirement IDs are qualified.** `readings.recording/REQ-003`, scenario
  `readings.recording/REQ-003/S2`. Tasks cite them in that form. Tests cite
  them verbatim in a comment or as `readings_recording_REQ_003_S2` in the
  name; `check-scenarios.sh` accepts either.
- **`check-scenarios.sh` with no arguments is a standing invariant on the
  living specs**: every live scenario has a test, and no test cites a removed
  requirement. It runs in converge and finish and is the coverage metric.
- **The first change is the degenerate case**: a delta that is all ADDED into
  a capability that does not exist yet. The merge creates the living spec from
  `templates/capability-template.md`, taking its Purpose from the proposal's
  Outcome. One loop from day one; no "initial build" mode.
- **Product-level documents evolve the same way, lightly.** `proposal.md`
  gains an `## Affects` section listing any living doc it modifies
  (`docs/domain.md`, `docs/glossary.md`, `docs/product.md`); those edits are
  gated re-approvals with `approve.sh` at finish, not silent changes.
- **The unit is a "change".** The word "slice" survives only as the adjective
  for a change's shape (thin, vertical). Directory, scripts, frontmatter and
  skills say change.
- **Change numbers are never reused**: `new-change.sh` counts archived
  changes when allocating.
- Skill names do not change (`sdd-specify` keeps its name; its job is now to
  write the proposal and deltas).

## Part 2 — Target layout

```
specs/                                CURRENT TRUTH (never hand-edited)
  index.md
  <context>/
    index.md
    <capability>.md                   type: Capability Spec; sdd_version; History
changes/                              PROPOSALS
  index.md
  NNN-slug/
    intent.md                         grill output (as now)
    proposal.md                       why, scope, domain, affects, edge cases, questions
    delta/<context>/<capability>.md   type: Spec Delta — ADDED / MODIFIED / REMOVED
    plan.md  tasks.md  notes.md
  archive/
    index.md
    NNN-slug/                         merged changes, complete, for history
.sdd/target/NNN-slug/                 preview of specs/ with the delta applied (ephemeral)
scripts/
  merge_delta.py                      preview | apply
  new-change.sh                       replaces new-feature.sh
  check-scenarios.sh                  living specs by default; --change for a target
  check-specs.sh                      living specs section + changes loop
  task-brief.sh                       requirements from the target state
  index.sh                            knows the new tree
templates/
  capability-template.md              seeds a living spec on first merge
  proposal-template.md                the old spec template minus Requirements
  delta-template.md
```

---

## Part 3 — Tasks

### Phase U — Scripts and templates

- [ ] **T401** · Create `templates/capability-template.md`:

~~~~markdown
---
type: Capability Spec
title: <context> / <capability>
description: <one sentence — what this capability does for its users>
resource: /specs/<context>/<capability>.md
status: draft
tags: [sdd, capability, "context:<context>"]
sources: []
generated:
  by: process:merge_delta.py
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_context: <context>
sdd_capability: <capability>
sdd_version: 0.0.0
---

# <context> / <capability>

> The current truth. Every requirement below is true of the system as it is
> now. Changes arrive as deltas under `changes/` and are merged here by
> `scripts/merge_delta.py` at `sdd-finish`. Never edited by hand.
>
> Cite a requirement as `<context>.<capability>/REQ-NNN` and a scenario as
> `<context>.<capability>/REQ-NNN/Sk`. IDs are never reused: a removed
> requirement stays, struck through, with the change that removed it.

## Purpose

<one paragraph>

## Requirements

## Invariants

| Invariant (from docs/domain.md) | Guarded by requirements |
|---|---|

## History

| Version | Date | Change | Added | Modified | Removed |
|---|---|---|---|---|---|
~~~~

  — verify: `./scripts/fm.py check templates/capability-template.md`

- [ ] **T402** · Create `templates/delta-template.md`:

~~~~markdown
---
type: Spec Delta
title: <context>.<capability> — delta for NNN-slug
description: <one sentence — what this change does to this capability>
resource: /changes/NNN-slug/delta/<context>/<capability>.md
status: draft
tags: [sdd, delta, "change:NNN-slug", "context:<context>"]
sources:
  - resource: /specs/<context>/<capability>.md
  - resource: /changes/NNN-slug/proposal.md
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_id: NNN-slug
sdd_context: <context>
sdd_capability: <capability>
---

# Delta: <context> / <capability>

> What this change does to the living spec `specs/<context>/<capability>.md`,
> and nothing else. Three sections, any of which may be empty and omitted.
> IDs: an ADDED requirement takes the next free `REQ-NNN` in the living spec
> (read it first; IDs are never reused, including removed ones). MODIFIED and
> REMOVED name existing IDs. `scripts/merge_delta.py` refuses anything else.
>
> If the capability does not exist yet, this delta is all ADDED starting at
> REQ-001, and the merge creates the living spec.

## ADDED

### REQ-00N: <short name>

<EARS sentence>

**Scenarios**
- **REQ-00N/S1 — <name>**
  Given <state>
  When <trigger>
  Then <observable outcome, real values>
- **REQ-00N/S2 — <failure name>**
  Given
  When
  Then

## MODIFIED

### REQ-00M: <short name — may change>

<the full new EARS sentence and full new scenario list; this replaces the block>

**Scenarios**
- **REQ-00M/S1 — <name>**
  Given
  When
  Then

**Was:**
> <the previous EARS sentence, verbatim, so the reviewer can see the diff>

## REMOVED

### REQ-00K: <its current name>
<one line: why it is no longer true, and what replaces it if anything>
~~~~

  — verify: `./scripts/fm.py check templates/delta-template.md`

- [ ] **T403** · Create `scripts/merge_delta.py`, `chmod +x`:

~~~~python
#!/usr/bin/env python3
"""Merge a change's delta specs into the living capability specs.

  merge_delta.py preview changes/NNN-slug [--out DIR]
      Write the merged result to DIR (default .sdd/target/NNN-slug/) without
      touching specs/. Used by task-brief.sh and the reviewers: the target
      state the change is aiming for.

  merge_delta.py apply changes/NNN-slug
      Merge in place into specs/<context>/<capability>.md. Used by sdd-finish
      after the user has approved and the slice has converged.

Delta format (changes/NNN/delta/<context>/<capability>.md): frontmatter, then
any of the H2 sections ADDED, MODIFIED, REMOVED. Each holds requirement
blocks `### REQ-NNN: title` up to the next `###`/`##`. A MODIFIED block may end
with a `**Was:**` quote; it is dropped on merge. A REMOVED block's body is the
reason.

Stdlib only. Exits 1 with a message on any inconsistency (adding an existing
id, modifying or removing a missing one, a delta with no sections).
"""
import re, sys, os, datetime, pathlib, shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import fm  # noqa: E402  (scripts/fm.py)

REQ_RE = re.compile(r"^### (~~)?(REQ-\d+)(?::\s*(.*?))?(~~)?\s*$")


def die(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def split_fm(text):
    fmv, body = fm.split(text)
    if fmv is None:
        die("file has no frontmatter")
    return fmv, body


def h2_sections(body_lines):
    """Map H2 heading -> list of lines (excluding the heading)."""
    out, cur = {}, None
    for l in body_lines:
        if l.startswith("## "):
            cur = l[3:].strip()
            out[cur] = []
        elif cur is not None:
            out[cur].append(l)
    return out


def req_blocks(lines):
    """Split lines into requirement blocks. Returns (preamble, [(id, block_lines)])."""
    pre, blocks, cur_id, cur = [], [], None, []
    for l in lines:
        m = REQ_RE.match(l)
        if m:
            if cur_id is not None:
                blocks.append((cur_id, cur))
            cur_id, cur = m.group(2), [l]
        elif cur_id is None:
            pre.append(l)
        else:
            cur.append(l)
    if cur_id is not None:
        blocks.append((cur_id, cur))
    return pre, blocks


def strip_trailing_blank(lines):
    while lines and lines[-1].strip() == "":
        lines.pop()
    return lines


def drop_was(block):
    """Remove a trailing **Was:** quote from a MODIFIED block."""
    for i, l in enumerate(block):
        if l.strip().startswith("**Was:**"):
            return strip_trailing_blank(block[:i])
    return strip_trailing_blank(block)


def title_of(block):
    m = REQ_RE.match(block[0])
    return (m.group(3) or "").strip()


def bump(ver, major):
    a, b, c = [int(x) for x in ver.split(".")]
    return f"{a+1}.0.0" if major else f"{a}.{b+1}.0"


def load_or_create(path, ctx, cap, change, proposal_outcome):
    if path.exists():
        return split_fm(path.read_text(encoding="utf-8")), False
    tpl = (ROOT / "templates" / "capability-template.md").read_text(encoding="utf-8")
    tpl = tpl.replace("<context>", ctx).replace("<capability>", cap)
    tpl = tpl.replace("at: YYYY-MM-DDTHH:MM:SSZ", "at: " + now())
    if proposal_outcome:
        tpl = tpl.replace("<one paragraph>", proposal_outcome)
    return split_fm(tpl), True


def now():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def proposal_outcome(change_dir):
    p = change_dir / "proposal.md"
    if not p.exists():
        return ""
    _, body = fm.split(p.read_text(encoding="utf-8"))
    secs = h2_sections(body or [])
    lines = [l for l in secs.get("Outcome", []) if l.strip() and not l.startswith("<")]
    return " ".join(l.strip() for l in lines)


def merge_one(delta_path, change, out_root, in_place):
    dfm, dbody = split_fm(delta_path.read_text(encoding="utf-8"))
    ctx = fm.scalar(dfm[fm.find_key(dfm, "sdd_context")].split(":", 1)[1]) if fm.find_key(dfm, "sdd_context") >= 0 else None
    cap = fm.scalar(dfm[fm.find_key(dfm, "sdd_capability")].split(":", 1)[1]) if fm.find_key(dfm, "sdd_capability") >= 0 else None
    if not ctx or not cap:
        die(f"{delta_path}: delta frontmatter needs sdd_context and sdd_capability")

    secs = h2_sections(dbody)
    added = req_blocks(secs.get("ADDED", []))[1]
    modified = req_blocks(secs.get("MODIFIED", []))[1]
    removed = req_blocks(secs.get("REMOVED", []))[1]
    if not (added or modified or removed):
        die(f"{delta_path}: no ADDED / MODIFIED / REMOVED requirement blocks")

    living_path = ROOT / "specs" / ctx / f"{cap}.md"
    src_path = living_path
    if not in_place and (out_root / ctx / f"{cap}.md").exists():
        src_path = out_root / ctx / f"{cap}.md"     # a previous delta in this change already touched it
    (lfm, lbody), created = load_or_create(src_path, ctx, cap, change, proposal_outcome(delta_path.parents[2]))

    lsecs_order = [l[3:].strip() for l in lbody if l.startswith("## ")]
    lsecs = h2_sections(lbody)
    head = []
    for l in lbody:
        if l.startswith("## "):
            break
        head.append(l)

    pre, blocks = req_blocks(lsecs.get("Requirements", []))
    index = {rid: i for i, (rid, _) in enumerate(blocks)}
    struck = {rid for rid, blk in blocks if blk[0].startswith("### ~~")}

    for rid, blk in added:
        if rid in index:
            die(f"{delta_path}: ADDED {rid} already exists in {living_path}")
        blk = strip_trailing_blank(list(blk)) + ["", f"_Since {change}_", ""]
        blocks.append((rid, blk))
        index[rid] = len(blocks) - 1
    for rid, blk in modified:
        if rid not in index or rid in struck:
            die(f"{delta_path}: MODIFIED {rid} does not exist (or was removed) in {living_path}")
        blk = drop_was(list(blk)) + ["", f"_Changed by {change}_", ""]
        blocks[index[rid]] = (rid, blk)
    for rid, blk in removed:
        if rid not in index or rid in struck:
            die(f"{delta_path}: REMOVED {rid} does not exist (or was already removed) in {living_path}")
        old_title = title_of(blocks[index[rid]][1])
        reason = " ".join(l.strip() for l in blk[1:] if l.strip()) or "no reason given"
        blocks[index[rid]] = (rid, [f"### ~~{rid}: {old_title}~~", "", f"_Removed by {change}: {reason}_", ""])

    # rebuild Requirements
    req_lines = strip_trailing_blank(list(pre))
    for _, blk in blocks:
        req_lines += [""] + strip_trailing_blank(list(blk))
    req_lines.append("")
    lsecs["Requirements"] = req_lines

    # history row
    date = now()[:10]
    hist = lsecs.get("History", [])
    row = f"| {{ver}} | {date} | {change} | {len(added)} | {len(modified)} | {len(removed)} |"
    # version
    i = fm.find_key(lfm, "sdd_version")
    cur = fm.scalar(lfm[i].split(":", 1)[1]) if i >= 0 else "0.0.0"
    newver = bump(cur, major=bool(removed))
    lfm = fm.cmd_set(lfm, "sdd_version", newver)
    hist = strip_trailing_blank(list(hist)) + [row.format(ver=newver), ""]
    lsecs["History"] = hist

    # sources: add the change's proposal
    src = f"  - resource: /changes/{change}/proposal.md"
    si = fm.find_key(lfm, "sources")
    if si < 0:
        lfm += ["sources:", src]
    else:
        val = lfm[si].split(":", 1)[1].strip()
        if val in ("[]", "~"):
            lfm[si:si + 1] = ["sources:", src]
        else:
            end = fm.block_end(lfm, si)
            if src not in lfm[si:end]:
                lfm[end:end] = [src]
    lfm = fm.cmd_set(lfm, "status", "stable")
    lfm = fm.cmd_set(lfm, "sdd_phase", "current")

    # reassemble body in original section order (new sections appended)
    body = list(head)
    seen = set()
    for name in lsecs_order:
        body += [f"## {name}"] + lsecs[name]
        seen.add(name)
    for name in lsecs:
        if name not in seen:
            body += [f"## {name}"] + lsecs[name]

    text = fm.join(lfm, body)
    if in_place:
        living_path.parent.mkdir(parents=True, exist_ok=True)
        living_path.write_text(text, encoding="utf-8")
        target = living_path
    else:
        target = out_root / ctx / f"{cap}.md"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
    verb = "created" if created else "merged into"
    print(f"{verb} {target}  (+{len(added)} ~{len(modified)} -{len(removed)}  v{newver})")


def main(argv):
    if len(argv) < 3 or argv[1] not in ("preview", "apply"):
        print(__doc__)
        return 2
    mode, change_dir = argv[1], pathlib.Path(argv[2].rstrip("/"))
    if not change_dir.is_absolute():
        change_dir = ROOT / change_dir
    if not change_dir.is_dir():
        die(f"{change_dir} is not a directory")
    change = change_dir.name
    out_root = None
    if mode == "preview":
        out_root = ROOT / ".sdd" / "target" / change
        if "--out" in argv:
            out_root = pathlib.Path(argv[argv.index("--out") + 1])
        if out_root.exists():
            shutil.rmtree(out_root)
        # seed the target with every living spec so unchanged capabilities are visible too
        specs = ROOT / "specs"
        if specs.is_dir():
            for p in specs.rglob("*.md"):
                if p.name in ("index.md", "log.md"):
                    continue
                rel = p.relative_to(specs)
                (out_root / rel).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(p, out_root / rel)
    deltas = sorted((change_dir / "delta").rglob("*.md")) if (change_dir / "delta").is_dir() else []
    deltas = [d for d in deltas if d.name != "index.md"]
    if not deltas:
        die(f"{change_dir}/delta has no delta files")
    for d in deltas:
        merge_one(d, change, out_root, in_place=(mode == "apply"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
~~~~

  — verify (functional, in a scratch copy of the repo so `specs/` stays clean):
  ```bash
  rm -rf /tmp/md && cp -r . /tmp/md && cd /tmp/md && mkdir -p changes/001-a/delta/readings specs
  printf -- '---\ntype: Change Proposal\nsdd_id: 001-a\n---\n## Outcome\nReadings can be recorded.\n' > changes/001-a/proposal.md
  printf -- '---\ntype: Spec Delta\nsdd_id: 001-a\nsdd_context: readings\nsdd_capability: recording\n---\n## ADDED\n### REQ-001: Record\nTHE SYSTEM SHALL record\n**Scenarios**\n- **REQ-001/S1 — records**\n  Given a\n  When b\n  Then c\n' > changes/001-a/delta/readings/recording.md
  ./scripts/merge_delta.py apply changes/001-a            # "created specs/readings/recording.md (+1 ~0 -0 v0.1.0)"
  mkdir -p changes/002-b/delta/readings
  printf -- '---\ntype: Spec Delta\nsdd_id: 002-b\nsdd_context: readings\nsdd_capability: recording\n---\n## REMOVED\n### REQ-001: Record\nreplaced\n## ADDED\n### REQ-002: Record with source\nTHE SYSTEM SHALL record with source\n**Scenarios**\n- **REQ-002/S1 — records**\n  Given a\n  When b\n  Then c\n' > changes/002-b/delta/readings/recording.md
  ./scripts/merge_delta.py preview changes/002-b          # writes .sdd/target/002-b/..., specs/ unchanged (still v0.1.0)
  ./scripts/fm.py get specs/readings/recording.md sdd_version   # 0.1.0
  ./scripts/merge_delta.py apply changes/002-b            # "+1 ~0 -1 v1.0.0"
  grep -c '^### ~~REQ-001' specs/readings/recording.md    # 1
  ./scripts/merge_delta.py apply changes/002-b; echo "exit=$?"   # error, exit=1
  cd - && rm -rf /tmp/md
  ```

- [ ] **T404** · Create `templates/proposal-template.md` from the spec template, then delete the spec template:
  ```bash
  sed -e 's/^type: Specification/type: Change Proposal/' \
      -e 's|resource: /specs/NNN-slug/spec.md|resource: /changes/NNN-slug/proposal.md|' \
      -e 's|"slice:NNN-slug"|"change:NNN-slug"|' -e 's|specification,|proposal,|' \
      -e 's|/specs/NNN-slug/intent.md|/changes/NNN-slug/intent.md|' \
      -e 's|^sdd_phase: draft          # draft \| in-review \| approved \| implemented \| superseded|sdd_phase: draft          # draft \| in-review \| approved \| merged|' \
      templates/spec-template.md > templates/proposal-template.md
  git rm -q templates/spec-template.md
  ```
  Then in `templates/proposal-template.md` replace everything from `## Requirements` up to (not including) `## Non-functional requirements` with:

~~~~markdown
## Changes

> Requirements live in the delta files, not here. One row per capability this
> change touches. `sdd-specify` writes the deltas from the intent; this table
> is the map.

| Capability | Delta file | Adds | Modifies | Removes | Why |
|---|---|---|---|---|---|
| `<context>.<capability>` | `delta/<context>/<capability>.md` | | | | |

## Affects

> Living documents this change modifies, other than the capability specs.
> Each is a gated re-approval at `sdd-finish`, never a silent edit.

| Document | Change | Approved at finish? |
|---|---|---|
| `docs/domain.md` | <new context / event / invariant, or "none"> | |
| `docs/glossary.md` | <new or changed terms, or "none"> | |
| `docs/product.md` | <scope or constraint change, or "none"> | |

~~~~

  Also change the heading `# Spec: <Feature name>` to `# Proposal: <Change name>` and the blockquote under it to: `> **WHAT and WHY only.** No library names, no schema, no file paths. The requirements themselves are in \`delta/\`; this document says why the change exists, what it touches, and what is out of scope.`
  — verify: `./scripts/fm.py check templates/proposal-template.md && grep -q '^## Changes' templates/proposal-template.md && ! test -f templates/spec-template.md`

- [ ] **T405** · `templates/intent-template.md`, `templates/plan-template.md`, `templates/tasks-template.md`: `sed -i -e 's|/specs/NNN-slug/|/changes/NNN-slug/|g' -e 's|"slice:NNN-slug"|"change:NNN-slug"|' templates/intent-template.md templates/plan-template.md templates/tasks-template.md`. In `templates/plan-template.md` and `templates/tasks-template.md` change `- resource: /changes/NNN-slug/spec.md` to `- resource: /changes/NNN-slug/proposal.md`. In `templates/tasks-template.md` change the example headings `### T010 · REQ-001 · <one outcome>` to `### T010 · <context>.<capability>/REQ-001 · <one outcome>` and the RED step text `scenario REQ-00X/S1` to `scenario <context>.<capability>/REQ-00X/S1`, and add to the intro blockquote: `Requirement and scenario IDs are qualified: \`<context>.<capability>/REQ-NNN\`. The brief pulls each cited requirement from the target state.` In the plan template's `## Requirement → design mapping` example row change `REQ-001` to `<context>.<capability>/REQ-001`.
  — verify: `grep -l 'changes/NNN-slug' templates/*.md | wc -l` prints `4` (intent, plan, tasks, proposal); `grep -q '<context>.<capability>/REQ-001' templates/tasks-template.md`.

- [ ] **T406** · Create `scripts/new-change.sh`, `chmod +x`; `git rm -q scripts/new-feature.sh`:

~~~~bash
#!/usr/bin/env bash
# Allocate the next change number, create changes/NNN-slug/, seed it from
# templates/, and optionally create a git branch. Numbers are never reused:
# archived changes count.
#
#   ./scripts/new-change.sh validate-on-entry
#   ./scripts/new-change.sh validate-on-entry --branch
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

SLUG="${1:-}"; MAKE_BRANCH=false; [[ "${2:-}" == "--branch" ]] && MAKE_BRANCH=true
if [[ -z "$SLUG" ]]; then
  echo "usage: $0 <kebab-case-slug> [--branch]" >&2
  echo "  slug describes the change, not the mechanism: validate-on-entry, not add-validator-class" >&2
  exit 1
fi
[[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "error: slug must be kebab-case: got '$SLUG'" >&2; exit 1; }

NEXT=1
HIGHEST=$( { ls -d changes/[0-9][0-9][0-9]-* changes/archive/[0-9][0-9][0-9]-* 2>/dev/null || true; } \
           | xargs -rn1 basename | sed 's/-.*//' | sort -n | tail -1)
[[ -n "${HIGHEST:-}" ]] && NEXT=$((10#$HIGHEST + 1))
NNN=$(printf "%03d" "$NEXT"); ID="${NNN}-${SLUG}"; DIR="changes/${ID}"
[[ -d "$DIR" ]] && { echo "error: $DIR already exists" >&2; exit 1; }

mkdir -p "$DIR/delta"
TODAY=$(date +%Y-%m-%d); NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CONST_VER=$(./scripts/fm.py get memory/constitution.md sdd_version 2>/dev/null || echo "0.0.0")

for t in intent proposal plan tasks; do
  sed -e "s|NNN-slug|${ID}|g" \
      -e "s|conversation:YYYY-MM-DD|conversation:${TODAY}|" \
      -e "s|at: YYYY-MM-DDTHH:MM:SSZ|at: ${NOW}|" \
      -e "s|^sdd_constitution: .*|sdd_constitution: ${CONST_VER}|" \
      "templates/${t}-template.md" > "${DIR}/${t}.md"
done

cat > "${DIR}/notes.md" <<NOTES
---
type: Implementation Notes
title: ${ID} — notes
description: Decisions taken during implementation that the plan did not cover.
resource: /changes/${ID}/notes.md
status: draft
tags: [sdd, notes, "change:${ID}"]
sdd_id: ${ID}
---

# Notes — ${ID}

Decisions taken during implementation that the plan did not cover, and why.
One line each, newest last.

NOTES

./scripts/index.sh >/dev/null
echo "created $DIR"; ls -1 "$DIR" | sed 's/^/  /'
if $MAKE_BRANCH && git rev-parse --git-dir >/dev/null 2>&1; then git checkout -b "$ID"; echo "on branch $ID"; fi
echo; echo "next: ${DIR}/intent.md  (the user's words — grill writes it)"
~~~~

  — verify: `mkdir -p changes/archive/007-old && ./scripts/new-change.sh smoke | head -1` prints `created changes/008-smoke`; `ls changes/008-smoke` shows `delta intent.md notes.md plan.md proposal.md tasks.md`; then `rm -rf changes/008-smoke changes/archive/007-old`.

- [ ] **T407** · Replace `scripts/check-scenarios.sh`:

~~~~bash
#!/usr/bin/env bash
# Scenario coverage against the living specs (the current truth):
#   every REQ in specs/<ctx>/<cap>.md has ≥1 scenario, every scenario has a
#   test citing it, and no test cites a scenario of a removed requirement.
#
#   ./scripts/check-scenarios.sh                       # living specs (standing check)
#   ./scripts/check-scenarios.sh --change changes/NNN  # the target state of one change:
#                                                      #   its ADDED/MODIFIED scenarios need tests,
#                                                      #   its REMOVED ones must have none
#
# A test cites a scenario by its qualified id, either form:
#   readings.recording/REQ-003/S1     (in a comment or docstring)
#   readings_recording_REQ_003_S1     (in the test name)
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
FAIL=0
TESTDIR="${SDD_TEST_DIR:-tests}"
ROOT_SPECS="specs"
ONLY_CHANGE=""

if [[ "${1:-}" == "--change" ]]; then
  ONLY_CHANGE="${2%/}"
  ./scripts/merge_delta.py preview "$ONLY_CHANGE" >/dev/null || { echo "❌ preview failed"; exit 1; }
  ROOT_SPECS=".sdd/target/$(basename "$ONLY_CHANGE")"
fi

cited() { # qualified id -> 0 if some test cites it, in either form
  local q="$1" u
  u=$(printf '%s' "$1" | tr './-' '___')
  [[ -d "$TESTDIR" ]] && grep -rqF -e "$q" -e "$u" "$TESTDIR" 2>/dev/null
}

# Which capabilities does this change touch? (all, for the standing check)
if [[ -n "$ONLY_CHANGE" ]]; then
  mapfile -t FILES < <(find "$ONLY_CHANGE/delta" -name '*.md' ! -name index.md 2>/dev/null | sed "s|^$ONLY_CHANGE/delta/|$ROOT_SPECS/|" | sort)
else
  mapfile -t FILES < <(find "$ROOT_SPECS" -mindepth 2 -name '*.md' ! -name index.md 2>/dev/null | sort)
fi
[[ ${#FILES[@]} -eq 0 ]] && { echo "no capability specs yet"; exit 0; }

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  ctx=$(./scripts/fm.py get "$f" sdd_context 2>/dev/null); cap=$(./scripts/fm.py get "$f" sdd_capability 2>/dev/null)
  q="$ctx.$cap"
  echo "$q"
  # live requirements
  for r in $(grep -oE '^### REQ-[0-9]+' "$f" | sed 's/### //' | sort -u); do
    scen=$(grep -oE "$r/S[0-9]+" "$f" | sort -u)
    if [[ -z "$scen" ]]; then echo "  ❌ $r has no scenario"; FAIL=1; continue; fi
    for s in $scen; do
      if cited "$q/$s"; then echo "  ✅ $q/$s tested"
      else echo "  ❌ $q/$s has no test citing it"; FAIL=1; fi
    done
  done
  # removed requirements must have no test left
  for r in $(grep -oE '^### ~~REQ-[0-9]+' "$f" | sed 's/### ~~//' | sort -u); do
    for s in $(grep -oE "$r/S[0-9]+" "$f" | sort -u); do
      if cited "$q/$s"; then echo "  ❌ $q/$s is removed but a test still cites it"; FAIL=1; fi
    done
    # removed blocks carry no scenarios (struck through), so also check by id
    if cited "$q/$r"; then echo "  ❌ $q/$r is removed but a test still cites it"; FAIL=1; fi
  done
done
[[ $FAIL -eq 0 ]] && echo "✅ scenario coverage complete" || echo "❌ scenario gaps"
exit $FAIL
~~~~

  — verify: `bash -n scripts/check-scenarios.sh && ./scripts/check-scenarios.sh` prints `no capability specs yet`.

- [ ] **T408** · Replace `scripts/task-brief.sh` (requirements now from the target state; cites qualified IDs):

~~~~bash
#!/usr/bin/env bash
# Build the self-contained brief for one task, so the implementer never reads
# the whole plan and the controller never pastes exact values by hand.
#
#   ./scripts/task-brief.sh changes/001-slug T011
#   → .sdd/briefs/001-slug/T011.md   (path printed)
#
# Requirements are taken from the TARGET state (living specs with this
# change's delta applied, via merge_delta.py preview), so the implementer sees
# what the capability must do after the change, not the delta alone.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

SLICE="${1:?usage: task-brief.sh changes/NNN-slug T0NN}"
SLICE="${SLICE%/}"
TID="${2:?usage: task-brief.sh changes/NNN-slug T0NN}"
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

TARGET=".sdd/target/$NAME"
./scripts/merge_delta.py preview "$SLICE" >/dev/null || { echo "error: could not build target state for $SLICE" >&2; exit 1; }

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
  echo "  - resource: /$SLICE/proposal.md"
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
  echo "## Requirements cited (verbatim from the target state of the capability)"
  # task heading cites qualified ids: <context>.<capability>/REQ-NNN
  for qr in $(printf '%s\n' "$TASK" | head -1 | grep -oE '[a-z0-9-]+\.[a-z0-9-]+/REQ-[0-9]+' | sort -u); do
    cc="${qr%%/*}"; r="${qr##*/}"; ctx="${cc%%.*}"; cap="${cc##*.}"
    tf="$TARGET/$ctx/$cap.md"
    echo; echo "**$qr** (from \`specs/$ctx/$cap.md\` after this change):"; echo
    if [[ -f "$tf" ]]; then section "$tf" "### $r"; else echo "_target spec $tf not found_"; fi
  done
  echo
  echo "## The delta this change makes (what is new or different)"
  for d in "$SLICE"/delta/*/*.md; do [[ -f "$d" ]] && { echo; echo "### $(basename "$(dirname "$d")").$(basename "$d" .md)"; sed '1,/^---$/{/^---$/!d}' "$d" | sed '1,/^---$/d'; }; done
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
~~~~

  — verify: `bash -n scripts/task-brief.sh && grep -q 'merge_delta.py preview' scripts/task-brief.sh`

- [ ] **T409** · `scripts/review-package.sh`: `sed -i -e 's|specs/NNN-slug|changes/NNN-slug|g' -e 's|specs/001-slug|changes/001-slug|g' -e 's|"slice:\$NAME"|"change:$NAME"|' scripts/review-package.sh`.
  — verify: `grep -q 'changes/NNN-slug' scripts/review-package.sh && bash -n scripts/review-package.sh`

- [ ] **T410** · Replace `scripts/index.sh`:

~~~~bash
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

# living specs: one index per context, one for specs/
for c in specs/*/; do
  [[ -d "$c" ]] && gen "${c%/}" "Capabilities: $(basename "$c")"
done
gen specs "Current specifications, by bounded context"
# changes: one index per change, one for archive, one for changes/
for ch in changes/[0-9][0-9][0-9]-*/ changes/archive/[0-9][0-9][0-9]-*/; do
  [[ -d "$ch" ]] && gen "${ch%/}" "Change $(basename "$ch")"
done
[[ -d changes/archive ]] && gen changes/archive "Shipped changes"
[[ -d changes ]] && gen changes "Changes in flight"
[[ -d docs/adr ]] && gen docs/adr "Architecture Decision Records"
gen docs "Project documents"
~~~~

  — verify: `mkdir -p changes && ./scripts/index.sh && test -f specs/index.md && test -f changes/index.md`

- [ ] **T411** · Replace `scripts/check-specs.sh`:

~~~~bash
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
echo "Living specs (specs/<context>/<capability>.md)"
NLIVE=0
for f in $(find specs -mindepth 2 -name '*.md' ! -name index.md 2>/dev/null | sort); do
  NLIVE=$((NLIVE+1))
  ctx=$(./scripts/fm.py get "$f" sdd_context 2>/dev/null || echo ""); cap=$(./scripts/fm.py get "$f" sdd_capability 2>/dev/null || echo "")
  ty=$(./scripts/fm.py get "$f" type 2>/dev/null || echo "")
  [[ "$ty" == "Capability Spec" ]] || bad "$f: type is '$ty', expected Capability Spec"
  [[ "$f" == "specs/$ctx/$cap.md" ]] || bad "$f: frontmatter says $ctx/$cap but path disagrees"
  if [[ -f docs/domain.md ]] && ! grep -qE "^\| *\`?$ctx\`? *\|" docs/domain.md; then
    bad "$f: context '$ctx' is not in docs/domain.md"
  fi
  for r in $(grep -oE '^### REQ-[0-9]+' "$f" | sed 's/### //'); do
    grep -qE "$r/S[0-9]+" "$f" || warn "$f: $r has no scenario"
  done
  if grep -niE '\b(postgres|mysql|sqlite|redis|kafka|react|vue|svelte|django|flask|fastapi|express|docker|kubernetes|graphql|grpc)\b' "$f" | grep -qv '^\s*[0-9]*:\s*>'; then
    warn "$f names a technology — that belongs in a plan"
  fi
  n=$(grep -cE '^### REQ-[0-9]+' "$f" || true); x=$(grep -cE '^### ~~REQ-[0-9]+' "$f" || true)
  echo "  $ctx.$cap  v$(./scripts/fm.py get "$f" sdd_version 2>/dev/null)  $n live, $x removed"
done
[[ $NLIVE -eq 0 ]] && echo "  (none yet — the first change creates them at sdd-finish)"

echo
if ! compgen -G "changes/[0-9][0-9][0-9]-*" > /dev/null; then
  echo "No changes in flight. ./scripts/new-change.sh <slug>"
  exit $FAIL
fi

echo "Changes in flight (changes/NNN-slug/)"
for d in changes/[0-9][0-9][0-9]-*/; do
  d="${d%/}"; id=$(basename "$d")
  echo "$id"

  [[ -f "$d/proposal.md" ]] || { bad "no proposal.md"; continue; }
  status=$(./scripts/fm.py get "$d/proposal.md" sdd_phase 2>/dev/null || echo "unset")
  echo "  proposal phase: $status"

  CUR_CONST=$(./scripts/fm.py get memory/constitution.md sdd_version 2>/dev/null || echo "")
  SPEC_CONST=$(./scripts/fm.py get "$d/proposal.md" sdd_constitution 2>/dev/null || echo "")
  if [[ -n "$CUR_CONST" && -n "$SPEC_CONST" && "$CUR_CONST" != "$SPEC_CONST" ]]; then
    warn "proposal written against constitution $SPEC_CONST; current is $CUR_CONST — re-check compliance"
  fi

  if [[ "$status" != "draft" && "$status" != "unset" ]]; then
    if [[ ! -f "$d/intent.md" ]]; then bad "no intent.md — the user's words were never recorded"
    elif [[ "$(./scripts/fm.py get "$d/intent.md" sdd_phase 2>/dev/null)" != "resolved" ]]; then warn "intent.md is not resolved but proposal is $status"; fi
  fi

  if [[ -f docs/roadmap.md ]] && ! grep -q "$id" docs/roadmap.md; then warn "$id is not listed in docs/roadmap.md"; fi

  ctx=$(./scripts/fm.py get "$d/proposal.md" sdd_context 2>/dev/null || echo "")
  if [[ -z "$ctx" || "$ctx" == "<context>" ]]; then
    [[ "$status" == "draft" ]] || warn "proposal has no sdd_context"
  elif [[ -f docs/domain.md ]] && ! grep -qE "^\| *\`?$ctx\`? *\|" docs/domain.md; then
    bad "sdd_context '$ctx' is not a context in docs/domain.md"
  fi

  # deltas
  ndelta=$(find "$d/delta" -name '*.md' 2>/dev/null | wc -l)
  if [[ "$ndelta" -eq 0 ]]; then
    [[ "$status" == "draft" ]] && echo "  · no delta yet (proposal in draft)" || bad "no delta files under $d/delta/"
  else
    echo "  ✅ $ndelta delta file(s)"
    for df in $(find "$d/delta" -name '*.md' | sort); do
      [[ "$(./scripts/fm.py get "$df" type 2>/dev/null)" == "Spec Delta" ]] || bad "$df: type must be Spec Delta"
      grep -qE '^## (ADDED|MODIFIED|REMOVED)' "$df" || bad "$df: no ADDED/MODIFIED/REMOVED section"
      for r in $(awk '/^## ADDED|^## MODIFIED/{p=1;next} /^## /{p=0} p' "$df" | grep -oE '^### REQ-[0-9]+' | sed 's/### //'); do
        grep -qE "$r/S[0-9]+" "$df" || warn "$df: $r has no scenario"
      done
      if grep -niE '\b(postgres|mysql|sqlite|redis|kafka|react|vue|svelte|django|flask|fastapi|express|docker|kubernetes|graphql|grpc)\b' "$df" | grep -qv '^\s*[0-9]*:\s*>'; then
        warn "$df names a technology — that belongs in plan.md"
      fi
    done
    # does it merge cleanly?
    if [[ "$status" != "draft" ]]; then
      ./scripts/merge_delta.py preview "$d" >/dev/null 2>/tmp/md.err || bad "delta does not merge: $(tail -1 /tmp/md.err)"
    fi
  fi

  UNTOUCHED=false
  grep -qE '<[A-Za-z][^>]*>' "$d/proposal.md" && { warn "proposal.md still contains template placeholders"; UNTOUCHED=true; }
  if $UNTOUCHED; then echo; continue; fi

  if [[ "$status" == "approved" ]] && awk '/^## Open questions/,/^## /' "$d/proposal.md" | grep -qE '^\| [0-9]+ \|[^|]*[A-Za-z]'; then
    warn "approved proposal still lists open questions"
  fi

  if [[ -f "$d/tasks.md" ]]; then
    for t in $(grep -oE '^### T[0-9]+' "$d/tasks.md" | sed 's/### //'); do
      blk=$(awk -v t="### $t " 'index($0,t)==1{p=1;print;next} p&&(/^### /||/^## /){exit} p{print}' "$d/tasks.md")
      for need in '\*\*Status:\*\*' '\*\*Files\*\*' '\*\*Steps\*\*' '\*\*Verify\*\*'; do
        printf '%s' "$blk" | grep -qE "$need" || warn "$t is missing $need"
      done
      printf '%s' "$blk" | grep -qE 'TBD|TODO|handle (edge|error) |error handling|similar to T|like T[0-9]' && warn "$t contains a placeholder phrase"
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
~~~~

  — verify: `bash -n scripts/check-specs.sh && ./scripts/check-specs.sh; true` shows a `Living specs` section and `No changes in flight`.

- [ ] **T412** · `scripts/hooks/guard-paths.sh` — add a case in the `case "$REL" in` block, before `memory/constitution.md)`:

~~~~bash
  specs/*/*.md)
    if [[ -f .sdd/unlock-specs ]]; then exit 0; fi
    echo "blocked: '$REL' is a living spec, merged by scripts/merge_delta.py at sdd-finish. Write a delta under changes/<id>/delta/ instead." >&2
    exit 2 ;;
~~~~

  — verify: `echo '{"tool_input":{"file_path":"'"$PWD"'/specs/readings/recording.md"}}' | ./scripts/hooks/guard-paths.sh; echo "exit=$?"` prints `exit=2`.

- [ ] **T413** · `.gitignore`: confirm `.sdd/` is listed (it is; `.sdd/target/` is covered). `specs/.gitkeep`: `git rm -q specs/.gitkeep` and instead commit `specs/index.md` (generated in T410). Create `changes/.gitkeep`? No: `changes/index.md` from T410 is enough.
  — verify: `git ls-files specs changes` lists `specs/index.md` and `changes/index.md`.

- [ ] **T414** · Commit: `feat(sdd): living capability specs, change proposals with deltas, merge and coverage tooling`

### Phase V — Skills

- [ ] **T415** · Replace `.claude/skills/sdd-specify/SKILL.md`:

~~~~markdown
---
type: Skill
name: sdd-specify
description: Write a change proposal and its delta specs — the WHAT and WHY of a change, and exactly which requirements it adds, modifies or removes in which living capability specs — into changes/NNN-slug/. Use after a grilling session, or when the user says "write the spec", "spec this", "propose this", "turn this into a spec". Writes no implementation code and never edits specs/ directly.
---

# Specify — propose a change

Produce `changes/NNN-slug/proposal.md` and one delta file per capability the
change touches, under `changes/NNN-slug/delta/<context>/<capability>.md`.
**No technology.** **Never edit `specs/`** — that is the current truth, and it
changes only when a delta is merged at `sdd-finish`.

## Before writing

1. Read `memory/constitution.md`. If `sdd_phase` is not `ratified` or it has
   placeholders, stop and run `sdd-constitution` first.
2. Read the `ears`, `ddd` and `bdd` skills.
3. Read `templates/proposal-template.md` and `templates/delta-template.md`.
4. Read `docs/product.md`, `docs/domain.md`, `docs/roadmap.md`,
   `docs/glossary.md`, `docs/decisions.md`, and this change's `intent.md`. If
   `intent.md` is missing or its `sdd_phase` is not `resolved`, stop and run
   `grill`. Do not re-ask anything `intent.md` answers.
5. **Read the living specs this change touches**, in full:
   `specs/<context>/<capability>.md` for every capability the intent names.
   Note the highest existing `REQ-` in each (including struck-through ones);
   ADDED requirements continue from there. If the capability does not exist
   yet, the delta is all ADDED from `REQ-001` and the merge will create it.
6. Copy `sdd_context` from `intent.md` to `proposal.md` (`fm.py set`).

## The change directory

It exists already; `grill` created it with `./scripts/new-change.sh`. If
somehow it does not, run it now.

## Writing the proposal

Fill `proposal.md` in this order:

1. **Problem** — what is wrong today, for whom, at what cost.
2. **Outcome** — what is true afterwards, observable from outside. (For a new
   capability this becomes the living spec's Purpose.)
3. **Scope, especially "explicitly out of scope".**
4. **Relationship to other changes** — depends on, affects.
5. **Domain** — context, nouns, events emitted/consumed, invariants preserved
   or introduced.
6. **Changes** — one row per capability touched: adds / modifies / removes
   counts and why. This is the map to the delta files.
7. **Affects** — any change to `docs/domain.md`, `docs/glossary.md` or
   `docs/product.md` this requires. "none" is a valid and common answer.
8. **Non-functional requirements**, **Edge cases**, **Assumptions**,
   **Open questions** — as before.

## Writing the deltas

One file per capability, from `templates/delta-template.md`, with
`sdd_context`, `sdd_capability` and `resource` set. Three sections; omit an
empty one.

- **ADDED** — new requirements. Next free ID. Full EARS sentence, full
  scenarios with real values, failure paths included.
- **MODIFIED** — an existing requirement whose sentence or scenarios change.
  Give the *complete* new block (it replaces the old one), then `**Was:**`
  quoting the old EARS sentence verbatim so the reviewer sees the diff. Keep
  the ID; the title may change. Scenario IDs may be reused or extended.
- **REMOVED** — an existing requirement that is no longer true. One line: why,
  and what replaces it. Its ID is never reused.

Then run `./scripts/merge_delta.py preview changes/NNN-slug`. It must succeed.
Read `.sdd/target/NNN-slug/<context>/<capability>.md`: that is what the
capability will say after the change. If it reads wrong, the delta is wrong.

## The discipline

- **No technology.** Not in the proposal, not in a delta.
- **One change, one outcome.** Do not bundle. If a delta touches four
  capabilities, ask whether it is two changes.
- **Never invent a MODIFIED.** If you cannot quote the old sentence from the
  living spec, it is not a modification.
- **Do not answer your own open questions.**
- **Scenarios are observable from outside the context.**
- **Glossary words, in this context's meaning.**
- **The smallest delta that leaves nothing to guess.**

## Gate

Report in at most six lines:

- The capabilities touched, with adds / modifies / removes per capability
- Anything you decided that the user did not specify
- Any Affects (domain, glossary, product) — each is its own re-approval later
- The open questions, numbered
- The riskiest assumption
- The preview merged cleanly (say so)

Then `AskUserQuestion`: *Approve*, *Revise*, *Answer open questions first*.

On approval: `./scripts/approve.sh changes/NNN-slug/proposal.md approved` and
`./scripts/approve.sh changes/NNN-slug/delta/<context>/<capability>.md approved`
for each delta; set the change's `docs/roadmap.md` status to `specified`;
`./scripts/index.sh`; commit `docs(proposal): NNN-slug — <title>`; hand to
`sdd-plan`.

**Do not write code in this turn.** Do not proceed to the plan without approval.
~~~~

  — verify: `grep -c 'merge_delta.py preview' .claude/skills/sdd-specify/SKILL.md` ≥ 1; `grep -q 'Never edit `specs/`' .claude/skills/sdd-specify/SKILL.md`.

- [ ] **T416** · Replace `.claude/skills/sdd-finish/SKILL.md`:

~~~~markdown
---
type: Skill
name: sdd-finish
description: Close out a converged change — merge its deltas into the living specs, re-approve any affected living docs, archive the change, choose merge / pull request / keep, update the roadmap. Use after sdd-converge reports Converged, or when the user says "finish", "ship it", "open the PR", "merge this", "we're done with this change". Adapted from obra/superpowers finishing-a-development-branch (MIT).
---

# Finish

Runs only after `sdd-converge` has reported **Converged** for the change. If it
has not, stop and say so.

## 1. Confirm the state

- `git status` clean; every task `**Status:** done`; `tasks.md`
  `sdd_phase: complete`; the convergence report at
  `.sdd/reports/<change>/converge.md`.
- `check` command green, run now, output shown.
- `./scripts/check-scenarios.sh --change changes/<id>` clean: every ADDED and
  MODIFIED scenario has a test; nothing cites a REMOVED one.
- `./scripts/check-specs.sh` clean for this change.

## 2. Merge the deltas into the living specs

This is the moment the current truth changes. It is the user's decision, made
when they approved the proposal; you are executing it.

1. `mkdir -p .sdd && touch .sdd/unlock-specs`
2. `./scripts/merge_delta.py apply changes/<id>` — for each capability this
   creates or updates `specs/<context>/<capability>.md`, bumps its version,
   appends the change to its sources and History.
3. For each capability touched:
   `./scripts/approve.sh specs/<context>/<capability>.md current` — the
   living spec now carries the user's verification for this change.
4. `rm -f .sdd/unlock-specs`
5. `./scripts/check-scenarios.sh` (no arguments) — the standing invariant over
   the living specs must be clean. If it is not, stop: something the reviewer
   missed is now in the truth. Report it before going on.

## 3. Apply the Affects

For each row in `proposal.md › Affects` that is not "none": propose the exact
edit to `docs/domain.md` / `docs/glossary.md` / `docs/product.md`, show the
diff, `AskUserQuestion` *Apply* / *Skip*. On apply: make the edit,
`./scripts/approve.sh <doc> approved`, bump `sdd_version` on `domain.md` if
it has one. Never silently.

## 4. Archive the change

- `./scripts/fm.py set changes/<id>/proposal.md sdd_phase merged`
- `git mv changes/<id> changes/archive/<id>`
- `docs/roadmap.md`: move the change's row from the active table to the
  `## Shipped` table, status `shipped`.
- `./scripts/index.sh`
- Commit: `feat(<id>): merge into specs — <capabilities> (<summary>)`

## 5. Ask — one question, four options, recommended first

Per `docs/engineering.md` §13, recommend the one it names:

- **Open a pull request (Recommended when a remote exists)** — PR title
  `<id>: <proposal title>`; body = the proposal's Outcome, each capability's
  delta summary (+adds ~modifies -removes), the convergence report, ADRs
  proposed. `git push` is denied to agents; give the user the exact commands.
- **Merge locally** — `git checkout main && git merge --squash <branch>` (or
  `--no-ff` per §13), delete the branch.
- **Keep the branch** — say why; note it in the roadmap row.
- **Discard** — only if the user says so explicitly, twice. Never recommend.

## 6. After

- Worktree, if used: `git worktree remove ../<repo>-<id>`.
- `.sdd/briefs/<id>`, `.sdd/reviews/<id>`, `.sdd/target/<id>`: delete.
- Say in four lines: which capabilities changed and to what version, what
  shipped, the next change on the roadmap, any open item carried forward.
  Offer `grill` for the next change.
~~~~

  — verify: `grep -q 'merge_delta.py apply' .claude/skills/sdd-finish/SKILL.md && grep -q 'unlock-specs' .claude/skills/sdd-finish/SKILL.md`

- [ ] **T417** · `.claude/skills/sdd/SKILL.md` — three edits:

  (a) In `## Step 2 — Read the state of the world`, replace item 6 with:
  ```
  6. `specs/index.md` — the living capabilities, by context. This is what the
     system does now; read the capability the request touches.
  7. `changes/index.md` — changes in flight; for each, the `sdd_phase` of
     `intent.md`, `proposal.md`, `plan.md`, `tasks.md`
     (`./scripts/fm.py get <file> sdd_phase`).
  ```
  and renumber the old item 7 (AGENTS.md) to 8; change `answers most of 3–7` to `answers most of 3–8`.

  (b) Replace the `## Step 3 — Dispatch` table with:
  ```
  | State | Next |
  |---|---|
  | `docs/product.md` missing or templated | `sdd-init` |
  | Constitution not ratified or has placeholders | `sdd-constitution` |
  | `docs/roadmap.md` has no approved changes | `sdd-init` (Step 6) |
  | User asks what the system does / how X works now | Read `specs/<context>/<capability>.md` and answer from it. No change needed. |
  | Request does not match a change in `docs/roadmap.md` | Ask whether to add it, and where. Then `grill`. |
  | Change exists, no `intent.md` or `intent.md` not `resolved` | `grill` |
  | `intent.md` resolved, `proposal.md` still template or no deltas | `sdd-specify` |
  | `proposal.md` written, `sdd_phase` not `approved` | Present it for approval — **stop** |
  | `proposal.md` approved, `plan.md` still template | `sdd-plan` (runs `sdd-engineering` first if `docs/engineering.md` is missing or unapproved) |
  | `plan.md` written, `sdd_phase` not `approved` | Present it for approval — **stop** |
  | `plan.md` approved, `tasks.md` still template | `sdd-tasks` |
  | `tasks.md` approved, tasks with `**Status:** todo` remain | `sdd-implement` |
  | All tasks `done` | `sdd-converge` |
  | Converge found gaps (appended tasks) | `sdd-implement` again |
  | Converge reports Converged | `sdd-finish` (merges the deltas into `specs/`) |
  ```

  (c) In `## Right-size` (Step 1), replace the **Small** bullet with:
  `- **Small** — a change whose delta is one MODIFIED requirement or a couple of ADDED scenarios, no new interface, no new dependency, no schema change. Propose: proposal + delta only, skip the plan. Wait for confirmation.`
  And add to `## Never`: `- Edit anything under \`specs/\`. It is the current truth and changes only by \`merge_delta.py\` at \`sdd-finish\`. Write a delta.`

  — verify: `grep -q 'changes/index.md' .claude/skills/sdd/SKILL.md && grep -q 'merges the deltas' .claude/skills/sdd/SKILL.md`

- [ ] **T418** · `.claude/skills/grill/SKILL.md`: `sed -i -e 's|specs/NNN-slug/intent.md|changes/NNN-slug/intent.md|g' -e 's|./scripts/new-feature.sh <slug>|./scripts/new-change.sh <slug>|g' -e 's|create the slice if it does not exist|create the change if it does not exist|' -e 's|approve.sh specs/NNN-slug/intent.md|approve.sh changes/NNN-slug/intent.md|' .claude/skills/grill/SKILL.md`. Then in `## What to grill on`, replace the **Context** paragraph's first two sentences with: `**Context and capability** — Which bounded context in \`docs/domain.md\` owns this, and which capability under \`specs/<context>/\`? Read the living spec first: half the questions below may already be answered by what is true today, and a change to existing behaviour must be framed as what it *modifies* or *removes*, not as a fresh feature.` Also in the Output section, `Add the slice to \`docs/roadmap.md\`` → `Add the change to \`docs/roadmap.md\``.
  — verify: `grep -q 'new-change.sh' .claude/skills/grill/SKILL.md && ! grep -q 'new-feature' .claude/skills/grill/SKILL.md`

- [ ] **T419** · `.claude/skills/sdd-plan/SKILL.md`, `.claude/skills/sdd-tasks/SKILL.md`, `.claude/skills/sdd-implement/SKILL.md`, `.claude/skills/sdd-converge/SKILL.md`, `.claude/agents/reviewer.md`, `.claude/agents/task-reviewer.md`, `.claude/agents/implementer.md`: `sed -i -e 's|specs/NNN-slug|changes/NNN-slug|g' -e 's|specs/<slice>|changes/<change>|g' -e 's|<slice>|<change>|g' -e 's|the slice|the change|g' -e 's|this slice|this change|g' -e 's|per slice|per change|g' -e 's|a slice|a change|g' -e 's|slice-level|change-level|g' -e 's|"slice:|"change:|g' <those seven files>`. Then, by hand:
  - `sdd-plan` › Before writing item 1: `Read the approved \`spec.md\` in full` → `Read the approved \`proposal.md\` and every delta under \`delta/\` in full, then run \`./scripts/merge_delta.py preview changes/NNN-slug\` and read the target state of each capability touched: the plan is for what the capability must do *after* the change`. Item 1's phase check applies to `proposal.md`.
  - `sdd-plan` › `## Requirement → design mapping` paragraph: `every requirement from the spec` → `every ADDED or MODIFIED requirement from the deltas, cited as \`<context>.<capability>/REQ-NNN\``.
  - `sdd-plan` › Gate: `approve.sh changes/NNN-slug/plan.md approved` (already via sed). The roadmap status line stays.
  - `sdd-tasks` › Before writing item 1: `Read the approved \`spec.md\` and \`plan.md\`` → `Read the approved \`proposal.md\`, its deltas, and \`plan.md\``; add item 4: `4. Run \`./scripts/merge_delta.py preview changes/NNN-slug\`. Tasks cite requirements by qualified ID (\`<context>.<capability>/REQ-NNN\`) and RED steps cite qualified scenario IDs; the brief pulls each from the target state.`
  - `sdd-tasks` › Coverage check: `Every requirement in the spec` → `Every ADDED and MODIFIED requirement in the deltas`; add: `Every REMOVED requirement has a task that deletes its tests and any code that only it needed, citing the qualified ID.`
  - `sdd-implement` › Before starting item 1: `spec.md`, `plan.md`, `tasks.md` → `proposal.md`, `plan.md`, `tasks.md`.
  - `sdd-converge` › `## How this phase runs` step 1: add `run \`./scripts/merge_delta.py preview changes/<change>\` and audit against the target state under \`.sdd/target/<change>/\`, and run \`./scripts/check-scenarios.sh --change changes/<change>\``. In `## Outcome`, the Converged bullet: remove `\`./scripts/approve.sh changes/<change>/spec.md implemented\`,` (the proposal is marked `merged` by finish) and keep the roadmap `converged` and hand-off to `sdd-finish`.
  - `reviewer.md` › step 2: `\`changes/<change>/spec.md\`` → `\`changes/<change>/proposal.md\`, every file under \`delta/\`, and the target state under \`.sdd/target/<change>/\``; step 3: `walk every \`REQ-\`` → `walk every ADDED and MODIFIED requirement in the deltas, and confirm every REMOVED one has no remaining test or dead code`; step 4: `check-scenarios.sh changes/<change>` → `check-scenarios.sh --change changes/<change>`; report frontmatter source `/changes/<change>/spec.md` → `/changes/<change>/proposal.md`.
  - `task-reviewer.md` › Stage 1 first bullet: `every cited \`REQ-\`` → `every cited qualified requirement (\`<context>.<capability>/REQ-NNN\`, from the brief's target-state section)`.
  — verify: `grep -rl 'specs/NNN-slug\|specs/<slice>\|<slice>' .claude/skills .claude/agents | wc -l` prints `0`; `grep -q 'merge_delta.py preview' .claude/skills/sdd-plan/SKILL.md .claude/skills/sdd-tasks/SKILL.md .claude/skills/sdd-converge/SKILL.md .claude/agents/reviewer.md`.

- [ ] **T420** · `.claude/skills/sdd-init/SKILL.md` — Step 6 (Roadmap): change `Decompose the product into **vertical slices**` to `Decompose the product into **changes**, each a thin vertical slice` and `Propose a first cut of 3–8 slices` to `Propose a first cut of 3–8 changes`; add after the "Does any slice span two contexts?" question: `- Which capability does each change create or modify? Name it (\`<context>.<capability>\`); the first changes create capabilities, later ones modify them.` Replace remaining `slice` with `change` in that step and in Step 8 (`start slice 1` → `start change 1`).
  — verify: `grep -c 'slice' .claude/skills/sdd-init/SKILL.md` ≤ 2 (the phrase "thin vertical slice" may remain).

- [ ] **T421** · `.claude/skills/sdd-constitution/SKILL.md` — no change. `.claude/skills/sdd-engineering/SKILL.md` — no change. `.claude/skills/ears/SKILL.md` — in `## Writing them`, add after the ID sentence: `In this repository IDs are qualified when cited from outside the spec: \`<context>.<capability>/REQ-004\`, scenario \`<context>.<capability>/REQ-004/S2\`.`
  — verify: `grep -q 'qualified' .claude/skills/ears/SKILL.md`

- [ ] **T422** · Commit: `feat(sdd): skills propose deltas, plan and implement against the target state, finish merges`

### Phase W — Docs

- [ ] **T423** · `templates/roadmap-template.md` — replace the table and the two lines above it (`> Statuses: …`) with:

~~~~markdown
> Statuses: `proposed` → `grilling` → `specified` → `planned` → `building` →
> `converged` → `shipped` · `deferred` · `dropped`. A shipped change moves to
> the table at the bottom so this one stays short.

| # | Change | Context | Capability (creates / modifies) | Outcome (one line) | Depends on | Status | Dir |
|---|---|---|---|---|---|---|---|
| 1 | | `<ctx>` | `<ctx>.<cap>` (creates) | | — | proposed | |
| 2 | | `<ctx>` | `<ctx>.<cap>` (modifies) | | 1 | proposed | |
~~~~

  and append at the end of the file:

~~~~markdown
## Shipped

| # | Change | Capability | Version after | Shipped |
|---|---|---|---|---|
~~~~

  Also `# Roadmap — vertical slices` → `# Roadmap — changes`, and in the first blockquote `Each slice is` → `Each change is a thin vertical slice:`.
  — verify: `grep -q '^## Shipped' templates/roadmap-template.md`

- [ ] **T424** · `docs/okf.md` — in the Types table, replace the five `specs/NNN/...` rows with:
  ```
  | `specs/<context>/<capability>.md` | `Capability Spec` | `current` (+ `sdd_version`, `sdd_context`, `sdd_capability`) |
  | `changes/NNN/intent.md` | `Intent` | `draft \| resolved` |
  | `changes/NNN/proposal.md` | `Change Proposal` | `draft \| in-review \| approved \| merged` |
  | `changes/NNN/delta/<context>/<capability>.md` | `Spec Delta` | `draft \| approved` |
  | `changes/NNN/plan.md` | `Implementation Plan` | `draft \| in-review \| approved` |
  | `changes/NNN/tasks.md` | `Task List` | `draft \| approved \| in-progress \| complete` |
  | `changes/NNN/notes.md` | `Implementation Notes` | — |
  ```
  Add to Common fields: `| \`sdd_capability\` | The capability a living spec or delta describes. Cited with its context as \`<context>.<capability>\`. |`. In the Rules list add: `- \`specs/**\` is written only by \`scripts/merge_delta.py\`; the hook blocks everything else.` In the Useful queries block add:
  ```bash
  # What does the system do now, in one context?
  cat specs/readings/index.md

  # Which changes shaped a capability?
  ./scripts/fm.py get specs/readings/recording.md sources   # (or read its History table)
  ```
  — verify: `grep -q 'Capability Spec' docs/okf.md && grep -q 'Spec Delta' docs/okf.md`

- [ ] **T425** · `AGENTS.md` — replace the `specs/NNN-slug/` line in `## Where things are` with:
  ```
  - `specs/<context>/<capability>.md` — **what the system does now.** One
    living spec per capability. Read it before touching that capability. Never
    edit it; it is merged from deltas at `sdd-finish`.
  - `changes/NNN-slug/` — a change in flight: `intent.md`, `proposal.md`,
    `delta/`, `plan.md`, `tasks.md`, `notes.md`. `changes/archive/` — shipped.
  ```
  In `## Never` add: `- Edit anything under \`specs/\`. Write a delta under \`changes/<id>/delta/\`; \`merge_delta.py\` is the only writer.` and change `- Rewrite an approved spec in place; propose a delta.` to `- Rewrite an approved proposal or delta in place after approval; open a new change.`
  — verify: `grep -q 'merge_delta.py' AGENTS.md`

- [ ] **T426** · `README.md` — edits (keep the file free of em/en dashes):
  (a) In "The idea in one minute" table, replace the `Slice intent`, `Specification` rows with:
  ```
  | Change intent | `changes/NNN/intent.md` | everything about one change, in your words, recorded as you answer |
  | Proposal + delta | `changes/NNN/proposal.md`, `delta/` | what and why, and exactly which requirements are added, modified or removed in which capability, no technology |
  ```
  and the `Plan` and `Tasks` rows' paths to `changes/NNN/`. Add a final row: `| Current truth | \`specs/<context>/<capability>.md\` | nothing; it is merged from approved deltas when a change ships, and it is what the system does now |`.
  (b) In the process diagram, `once per slice` → `once per change`; `sdd-specify    → spec.md` → `sdd-specify    → proposal + delta`; `sdd-finish     → merge / PR / keep` → `sdd-finish     → merge delta into specs/, PR`.
  (c) In `### Per phase`, `sdd-specify` paragraph: replace with `\`sdd-specify\` turns the intent into a proposal and one or more deltas: what and why in \`proposal.md\`, and in \`delta/<context>/<capability>.md\` exactly which requirements are added, modified or removed in the living spec, each with Given/When/Then scenarios carrying real values. A modified requirement shows its old sentence so the diff is visible. The delta is previewed against the current truth before you see it, so a change that would add an ID that exists or modify one that does not is caught here. Gate.` And add a new paragraph after `sdd-converge`: `\`sdd-finish\` is where the truth changes. It merges the deltas into \`specs/<context>/<capability>.md\`, bumps the capability's version, records the change in its history, re-runs the standing coverage check, applies any approved edits to the domain map or glossary, archives the change, and offers a PR. From then on the living spec is what the system does, and the next change is written against it.` Delete the old `sdd-finish` paragraph.
  (d) In `## The artefacts` tree, replace the `specs/NNN-slug/` block with:
  ```
  specs/                  what the system does NOW, by bounded context
    <context>/
      <capability>.md     living spec: every true requirement, versioned, with history
  changes/                what is being changed
    NNN-slug/             one directory per change
      intent.md           your words, Q&A record
      proposal.md         WHAT and WHY; which capabilities it touches; what it affects
      delta/<ctx>/<cap>.md  ADDED / MODIFIED / REMOVED requirements against the living spec
      plan.md             HOW: stack, data, interfaces, structure, risks
      tasks.md            self-contained task blocks
      notes.md            decisions taken during implementation
    archive/              shipped changes, kept for history
  ```
  (e) New section after `## The model ladder`:

~~~~markdown
## How the product evolves

The specs are not a changelog. `specs/` holds one living document per
capability, and it is the only place that says what the system does now.
Every change, from the first feature to a one-line rule tweak years later, is
the same shape: an intent in your words, a proposal, and a delta that says
what is added, modified or removed in which capability. Until the change
ships, everyone works against a preview of the living spec with the delta
applied. When it ships, the delta is merged in, the capability's version goes
up, the change is archived, and the next change is written against the new
truth.

A removed requirement stays in the living spec, struck through, with the
change that removed it. IDs are never reused. A capability's history table
lists every change that shaped it. So "what does readings do" is one file,
"why does it do that" is its sources, and "what did we think last spring" is
the archive.

The first change is not special: it is a delta that is all ADDED into a
capability that does not exist yet, and the merge creates it. There is no
initial-build mode and no migration to an evolution mode.
~~~~

  (f) In `## Scripts` table: replace the `new-feature.sh` row with `| \`new-change.sh <slug> [--branch]\` | allocates the next change number (archived ones count), seeds the change from templates |`; add `| \`merge_delta.py preview\|apply <change>\` | previews a change's deltas against the living specs into \`.sdd/target/\`, or merges them in at finish |`; update `check-scenarios.sh` to `every live scenario has a test and no test cites a removed requirement; \`--change\` checks a change's target state`.
  (g) In `## What the agent is not allowed to do`: add a paragraph `It cannot edit a living spec. \`specs/**\` is blocked by the hook; the only writer is \`merge_delta.py\`, at finish, after you approved the delta and the change converged.`
  (h) `## Day to day` table: add `| "what does X do now" | reads \`specs/<context>/<capability>.md\` and answers; no change opened |` and `| "change how X works" | \`grill\` on the existing capability, then a delta with MODIFIED and REMOVED entries |`.
  (i) In `## What it is built from`: after the Spec Kit line add `- Living specs plus change proposals with delta specs, merged on ship, come from OpenSpec.`
  — verify: `grep -q 'How the product evolves' README.md`; `python3 -c "t=open('README.md').read(); print(t.count(chr(8212))+t.count(chr(8211)))"` prints `0`; `! grep -q 'new-feature' README.md`.

- [ ] **T427** · `docs/sdd-guide.md` — the same substance, shorter (no em/en dashes): `## What is here` tree as in T426(d); `new-feature.sh` → `new-change.sh` and add `merge_delta.py`; in the skills table `sdd-specify` → `Writes the proposal and the deltas.`, `sdd-finish` → `Merges the deltas into the living specs, archives the change, PR.`; a new section `## Living specs and changes` with the first two paragraphs of T426(e); Credits: add the OpenSpec line.
  — verify: `grep -q 'Living specs and changes' docs/sdd-guide.md && ! grep -q 'new-feature' docs/sdd-guide.md`

- [ ] **T428** · `templates/README-project.md`: after the roadmap sentence add `What the system does now is in [\`specs/\`](specs/index.md), one living spec per capability.`
  — verify: `grep -q 'specs/index.md' templates/README-project.md`

- [ ] **T429** · Commit: `docs(sdd): living specs and changes in README, guide, okf, AGENTS.md, roadmap`

### Phase X — Verify

- [ ] **T430** · Frontmatter: 16 skills + 3 agents = **19** ok lines (loop from part 4, T334).

- [ ] **T431** · No stale paths: `grep -rn 'specs/NNN\|new-feature\|specs/<slice>\|"slice:' --include=*.md --include=*.sh --include=*.py . | grep -v upgrade-plan-5 | grep -v '^./.git/'` prints nothing.

- [ ] **T432** · Full functional walk, in a scratch copy, following the exact sequence a project will:
  ```bash
  rm -rf /tmp/w && cp -r . /tmp/w && cd /tmp/w && rm -rf .git && git init -q
  ./scripts/new-change.sh record-reading >/dev/null
  # write a minimal proposal + all-ADDED delta (copy the T403 verify's delta into changes/001-record-reading/delta/readings/recording.md, and put "## Outcome" + a sentence into proposal.md)
  ./scripts/merge_delta.py preview changes/001-record-reading          # ok, creates .sdd/target/...
  printf -- '---\ntype: Implementation Plan\n---\n## Interfaces\nx\n' > changes/001-record-reading/plan.md
  printf -- '\n### T001 · readings.recording/REQ-001 · Record\n\n**Status:** todo\n**Files**\n- x\n**Steps**\n- [ ] 1. RED — scenario readings.recording/REQ-001/S1\n**Verify** — x\n' >> changes/001-record-reading/tasks.md
  ./scripts/task-brief.sh changes/001-record-reading T001 >/dev/null && grep -q 'readings.recording/REQ-001' .sdd/briefs/001-record-reading/T001.md && echo "brief ok"
  mkdir -p tests/readings && echo 'def test_readings_recording_REQ_001_S1(): pass' > tests/readings/test_r.py
  ./scripts/check-scenarios.sh --change changes/001-record-reading | tail -1   # ✅
  mkdir -p .sdd && touch .sdd/unlock-specs && ./scripts/merge_delta.py apply changes/001-record-reading && rm .sdd/unlock-specs
  ./scripts/check-scenarios.sh | tail -1                                        # ✅ (standing)
  git add -A >/dev/null; git mv changes/001-record-reading changes/archive/001-record-reading
  ./scripts/index.sh >/dev/null && cat specs/index.md changes/archive/index.md
  ./scripts/check-specs.sh; true
  cd - && rm -rf /tmp/w
  ```
  — verify: each command behaves as its comment says; `check-specs.sh` shows `readings.recording  v0.1.0  1 live, 0 removed`.

- [ ] **T433** · OKF sweep: `for f in $(find docs specs changes memory templates .claude -name '*.md' ! -name index.md ! -name log.md); do ./scripts/fm.py check "$f"; done | grep -c FAIL` prints `0`.

- [ ] **T434** · `git rm docs/upgrade-plan-5.md`; commit: `chore(sdd): v5 — living specs and changes, verified`.

## Deferred

- A `capability` skill for splitting or merging capabilities (renames, moving
  requirements between files) — until it is needed, do it by hand as a
  change with REMOVED in one delta and ADDED in another.
- Cross-capability requirement references (`depends on
  billing.invoicing/REQ-002`) — free text in the EARS sentence for now.
- Rendering the archive as a changelog — `changes/archive/index.md` plus each
  capability's History table is enough to start.
- `merge_delta.py` handling two deltas for the same capability in one change
  in `apply` mode: works in `preview`; in `apply` each delta reads the file
  after the previous one wrote it, so it also works, but is untested. Keep to
  one delta per capability per change.
