---
type: Guide
title: Upgrade plan 4 — DDD and BDD
description: Change plan adding minimal Domain-Driven Design (contexts, ubiquitous language, events, invariants) and Behaviour-Driven acceptance tests to the workflow.
resource: /docs/upgrade-plan-4.md
status: draft
tags: [sdd, plan, upgrade]
---

# sdd-starter — upgrade plan part 4: DDD and BDD

**Executor:** a cheaper model. Every task is mechanical: file, exact content or
exact edit, verify line. If a task is ambiguous, stop and ask. Work in the
repository root. Commit after each phase with the message given. Delete this
file in the final task.

**Baseline:** the repository as pushed to `mjftw/sdd-starter` (single commit
`feat: spec-driven development starter`, 52 files). All paths below are
relative to its root.

---

## Part 1 — What is being added, and what is deliberately not

### DDD — the minimal set

Four things carry almost all of DDD's value for keeping agent-built code
organised. Each maps onto something the workflow already has, so the change is
mostly "make an existing artefact context-aware" rather than "add a ceremony".

| DDD idea | What it does here | Where it lands |
|---|---|---|
| **Bounded contexts + context map** | The product is divided into named contexts, each owning its own model and vocabulary. Code layout mirrors them one-to-one. Every slice belongs to exactly one context. The map is enforceable: a script checks that code in one context only reaches another through its published interface. | `docs/domain.md`; `sdd_context` on every slice artefact; `scripts/check-contexts.sh`; plan's Structure section |
| **Ubiquitous language, scoped** | The glossary already exists; it becomes per-context. The same word in two contexts is two entries with two meanings. Code, tests and specs use the context's word. | `docs/glossary.md` gains a Context column and a rule |
| **Invariants (aggregates, without the vocabulary)** | Each context states the rules that must always hold ("an order's line total never exceeds its credit limit"). They become EARS ubiquitous requirements and property/invariant tests. The "aggregate" is simply the thing that guards an invariant; we name the invariant, not the pattern. | `docs/domain.md` per context; spec `## Domain` section; a BDD scenario per invariant |
| **Domain events as the published language** | Contexts talk through named, past-tense, schema-first events (`ReadingRecorded`), never by reaching into each other's tables or types. This is the anti-corruption layer made concrete, and it matches the engineering default of ports & adapters and schema-first interfaces. | `docs/domain.md` event table; spec `## Domain` lists events emitted/consumed; plan's Interfaces |

**Explicitly skipped** (the academic bloat): entity/value-object taxonomy as a
required classification (the "types" preference already says make illegal
states unrepresentable, which is what value objects are for); repositories,
factories, domain services and application services as mandated layers (the
plan chooses structure per context; ports & adapters already covers it);
formal event-storming workshops (the init interview does a five-question
version); strategic-pattern names on the context map (Conformist, Open Host,
Shared Kernel — the map records *direction* and *mechanism*, which is what an
agent needs, and skips the taxonomy).

### BDD — the minimal set

BDD here is a **test-writing discipline**, not a tooling adoption. No Gherkin
runner is required; the plan may choose one if the stack has a good one.

| BDD idea | What it does here | Where it lands |
|---|---|---|
| **Scenarios in Given / When / Then** | Every requirement's acceptance criteria are rewritten as scenarios: a starting state, a trigger, an observable outcome, with real values. EARS states the rule; the scenario is the example that proves it. Each scenario has an ID (`REQ-004/S2`). | spec template Requirements section; `ears` skill gets the mapping |
| **Tests are scenarios** | One test per scenario, named after it, citing its ID. The test drives the context through its public interface only. Litmus: *could the implementation be rewritten from scratch without touching this test?* If not, the test is coupled to implementation and is rejected in review. | `bdd` skill; task anatomy RED step; `task-reviewer` Stage 1; `REVIEW.md` pass 1 |
| **Doubles only at ports** | Fakes stand in for the database, clock, network, other contexts — never for the context's own internals. Mocks that assert on internal calls are forbidden. | `bdd` skill; engineering §7 default tightened |
| **Scenario coverage is the coverage metric** | Converge checks every scenario has a test, every test cites a scenario. Replaces line coverage as the number that matters. | `scripts/check-scenarios.sh`; `REVIEW.md` pass 1; `sdd-converge` |

### How the two fit the existing ladder

```
sdd-init      → product brief → domain discovery (docs/domain.md) → roadmap (slices tagged with context)
grill         → asks which context; a slice spanning contexts is a finding, not a default
sdd-specify   → ## Domain section; scenarios per requirement; invariants as ubiquitous REQs
sdd-plan      → structure mirrors contexts; events schema-first; ACL at boundaries
sdd-tasks     → RED steps cite scenario IDs
implementer   → bdd skill: test through the port, name after scenario
task-reviewer → rejects implementation-coupled tests
sdd-converge  → check-scenarios.sh (every scenario tested), check-contexts.sh (no boundary leaks)
```

---

## Part 2 — Target additions

```
docs/domain.md                    context map: contexts, ownership, events, invariants, relationships
templates/domain-template.md
scripts/check-contexts.sh         boundary check: cross-context imports only via published interface
scripts/check-scenarios.sh        every REQ has ≥1 scenario; every scenario has a test citing it
.claude/skills/bdd/SKILL.md       scenarios → tests, no implementation coupling, doubles at ports
.claude/skills/ddd/SKILL.md       reference: contexts, language, events, invariants — and what we skip
```

Changed: `sdd-init`, `grill`, `sdd-specify`, `sdd-plan`, `sdd-tasks`,
`sdd-converge`, `ears`, `task-reviewer`, `reviewer`, spec/plan/tasks/glossary/
engineering templates, `REVIEW.md`, `check-specs.sh`, `okf.md`, `sdd-guide.md`,
`AGENTS.md`.

---

## Part 3 — Tasks

### Phase P — Domain map

- [ ] **T301** · Create `templates/domain-template.md`:

~~~~markdown
---
type: Domain Map
title: Domain map
description: The bounded contexts of this product, what each owns, the events between them, and the invariants each protects.
resource: /docs/domain.md
status: draft
tags: [sdd, domain]
sources:
  - resource: conversation:YYYY-MM-DD
  - resource: /docs/product.md
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_phase: draft          # draft | approved
---

# Domain map

> The product divided into **bounded contexts**: areas that each own one model
> and one vocabulary. Code layout mirrors this map one-to-one. A slice belongs
> to exactly one context. Contexts talk through the events and interfaces
> listed here and in no other way — `scripts/check-contexts.sh` enforces it.
>
> Keep this short. A context that cannot be described in two lines is two
> contexts. Three to seven contexts is normal for a product; one is fine for a
> small one.

## Contexts

| Context | Owns (the nouns) | Responsible for (the verbs) | Not responsible for | Code root |
|---|---|---|---|---|
| `<name>` | | | | `src/<name>/` |

## Relationships

> Direction and mechanism only. Upstream publishes; downstream consumes and
> translates at its own boundary (anti-corruption). No context imports another
> context's internals.

| Upstream | Downstream | Mechanism | Translation needed? |
|---|---|---|---|
| `<ctx>` | `<ctx>` | event `<Name>` / interface `<name>` | |

## Events

> Past tense. Named in the upstream context's language. Schema-first — the
> schema is the contract (see engineering §8). One row per event.

| Event | Emitted by | Consumed by | Carries | Schema |
|---|---|---|---|---|
| `<NounVerbed>` | `<ctx>` | `<ctx>` | | `<path>` |

## Invariants

> The rules that must hold at all times inside a context. Each becomes an
> EARS ubiquitous requirement and at least one scenario/property test. The
> thing that guards an invariant is that context's aggregate — we name the
> rule, not the pattern.

| Context | Invariant (one sentence, testable) | Guarded by |
|---|---|---|
| `<ctx>` | | `<the noun that owns it>` |

## Shared

> Things deliberately used across contexts unchanged. Keep this nearly empty;
> each row is a coupling.

- 

## Open questions

| # | Question | Recommended answer |
|---|---|---|
~~~~

  — verify: `./scripts/fm.py check templates/domain-template.md`

- [ ] **T302** · `scripts/init.sh` — change `for t in product roadmap glossary; do` to `for t in product domain roadmap glossary; do`.
  — verify: `grep -q 'product domain roadmap glossary' scripts/init.sh`

- [ ] **T303** · `templates/glossary-template.md` — replace the table with:

~~~~markdown
| Term | Context | Means | Not to be confused with | First used in |
|---|---|---|---|---|
| | | | | |
~~~~

  and add to the intro blockquote: `The same word can mean different things in different contexts — that is two rows, and code in each context uses its own meaning. A term used across contexts unchanged is listed under Shared in docs/domain.md.`
  — verify: `grep -q '| Term | Context |' templates/glossary-template.md`

- [ ] **T304** · Create `scripts/check-contexts.sh`, `chmod +x`:

~~~~bash
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
~~~~

  — verify: `bash -n scripts/check-contexts.sh && ./scripts/check-contexts.sh` prints `no docs/domain.md — nothing to check`.

- [ ] **T305** · Commit: `feat(ddd): domain map template, context-aware glossary, boundary check`

### Phase Q — Scenarios and BDD

- [ ] **T306** · `templates/spec-template.md` — three edits:

  (a) Frontmatter: after `sdd_id: NNN-slug` add `sdd_context: <context>`.

  (b) Insert this section after `## Relationship to other slices` and before `## Requirements`:

~~~~markdown
## Domain

> From `docs/domain.md`. One context per slice. If this slice needs two, stop:
> either it is two slices, or it is an integration slice whose only job is the
> event/interface between them.

- **Context:** `<name>`
- **Nouns touched:** <from the context's Owns column; glossary terms exactly>
- **Events emitted:** `<NounVerbed>` — <when>
- **Events consumed:** `<NounVerbed>` from `<context>` — <what we do with it>
- **Invariants this slice must preserve:** <from the map; each becomes a REQ below>
- **New invariants this slice introduces:** <each becomes a REQ and a row in the map>
~~~~

  (c) Replace the two example requirement blocks (`### REQ-001` through the end of `### REQ-002`'s `**Traces to:**`) with:

~~~~markdown
### REQ-001: <short name>

THE SYSTEM SHALL <observable behaviour>

**Scenarios** — Given / When / Then, real values, observable from outside the
context. One per acceptance path, including the failure paths.

- **REQ-001/S1 — <scenario name>**
  Given <starting state, concrete>
  When <the trigger, concrete>
  Then <the observable outcome, with the actual values>
- **REQ-001/S2 — <failure scenario name>**
  Given <state>
  When <trigger that should be rejected>
  Then <the rejection, exactly as the user sees it>

**Traces to:** <task IDs, filled in by /sdd-tasks>

### REQ-002: <short name>

WHEN <trigger>
THE SYSTEM SHALL <response>

**Scenarios**

- **REQ-002/S1 — <name>**
  Given
  When
  Then

**Traces to:**
~~~~

  — verify: `grep -c 'REQ-001/S' templates/spec-template.md` prints `2`; `grep -q 'sdd_context' templates/spec-template.md`; `grep -q '^## Domain' templates/spec-template.md`.

- [ ] **T307** · `templates/plan-template.md`, `templates/tasks-template.md`, `templates/intent-template.md` — add `sdd_context: <context>` after `sdd_id: NNN-slug` in each frontmatter.
  — verify: `grep -l 'sdd_context' templates/*.md | wc -l` prints `4`.

- [ ] **T308** · `templates/plan-template.md` — replace the `## Structure` section body with:

~~~~markdown
> Mirrors `docs/domain.md`. Everything this slice adds lives under its
> context's code root. Anything another context may use goes under
> `published/` (the context's interface and event schemas); everything else is
> internal and `scripts/check-contexts.sh` will fail a cross-context import of
> it. Inside the root, ports & adapters per engineering §6: pure domain, ports
> as interfaces, adapters at the edge.

```
src/<context>/
  published/        ← interface + event schemas other contexts may depend on
  domain/           ← pure: the nouns, the invariants, no IO
  ports/            ← interfaces the domain needs (repo, clock, bus…)
  adapters/         ← implementations of ports; translation from other contexts' events
tests/<context>/
  scenarios/        ← one test per spec scenario, through the published interface or driving port
  invariants/       ← property/invariant tests
```
~~~~

  And in the `## Interfaces` body, append: `Events this slice emits or consumes are listed with their schema path. A consumed event from another context is translated into this context's own types at the adapter — never used raw inside the domain.`
  — verify: `grep -q 'published/' templates/plan-template.md`

- [ ] **T309** · `templates/tasks-template.md` — in the T001 example, change step 1 from `RED — write the failing test (the actual test code):` to `RED — scenario REQ-00X/S1: write the failing test, named after the scenario, through the published interface (the actual test code):`. Add to the intro blockquote: `Every RED step names the scenario ID it proves. A task with no scenario is Foundations or Hardening.`
  — verify: `grep -q 'REQ-00X/S1' templates/tasks-template.md`

- [ ] **T310** · Create `.claude/skills/bdd/SKILL.md`:

~~~~markdown
---
type: Skill
name: bdd
description: Behaviour-driven testing discipline — turn a spec scenario (Given/When/Then) into a test that exercises the context through its public interface only, so the implementation can be rewritten without touching the test. Use whenever writing a test, whenever a task's RED step cites a scenario ID, and whenever reviewing whether a test is coupled to implementation.
---

# BDD — tests are the spec's scenarios

The spec states behaviour as scenarios. A test is a scenario made executable.
Nothing else is a test.

## The one rule

**Could the implementation be rewritten from scratch — different data
structures, different modules, different algorithm — and this test still
pass without being edited?** If not, the test is coupled to implementation.
Rewrite it or delete it.

## Shape

One test per scenario. Named after it. Citing its ID.

```python
def test_REQ_004_S2_fifth_failed_login_within_15_minutes_is_rate_limited():
    # Given: four failed attempts from 203.0.113.9 in the last 14 minutes
    clock = FakeClock(start="2026-09-19T10:00:00Z")
    auth = build_auth_context(clock=clock, users=[User("ada", password="right")])
    for _ in range(4):
        auth.login(ip="203.0.113.9", username="ada", password="wrong")
    # When: a fifth attempt arrives
    result = auth.login(ip="203.0.113.9", username="ada", password="wrong")
    # Then: it is rejected as rate-limited, with the retry window from the spec
    assert result == LoginRejected(reason="rate_limited", retry_after_s=60)
```

Notice what the test touches: the context's **public interface**
(`build_auth_context`, `login`) and its **published result types**
(`LoginRejected`). Notice what it does not touch: the counter, the store, the
hashing, the module layout. Those can all change.

## Given / When / Then

- **Given** — build the starting state through the public interface or a
  fake at a port (a `FakeClock`, an in-memory repository). Never by writing
  to internal state directly.
- **When** — exactly one trigger. The thing the requirement's `WHEN` names.
- **Then** — assert on what is observable from outside the context: the
  return value, the emitted event, the state visible through the interface.
  Use the real values from the scenario. One scenario, one behaviour; if you
  need three unrelated assertions you have three scenarios.

## Test doubles — only at ports

Fakes replace things *outside* the context: the database, the clock,
randomness, the network, another context (by feeding it that context's
events). They are simple, real implementations of the port — an in-memory
map, a settable clock — not mocks.

Forbidden:
- A mock that asserts *how* the code called something ("repository.save was
  called once with…"). That is implementation.
- Patching or replacing anything inside the context's own domain or
  application code.
- Reaching into private state to set up Given or to assert Then.
- Sleeping, ordering dependence between tests, shared mutable fixtures.

## Invariants

An invariant from `docs/domain.md` gets a test that tries to break it and
fails to. Where the language has a property-based library, use it: generate
inputs, assert the invariant holds after every operation. Otherwise, a
scenario per way it could be violated.

## Naming and location

- File: `tests/<context>/scenarios/test_<requirement-topic>.py` (or the
  stack's equivalent).
- Test: `test_<REQ>_<S>_<scenario name in snake case>`. The ID must appear
  verbatim so `scripts/check-scenarios.sh` can find it.
- Use glossary terms for the context. Not synonyms.

## When the scenario is wrong

If a scenario cannot be written as a test through the public interface,
the scenario is describing implementation, not behaviour — or the interface
is missing something. Either way it is a **spec finding**: stop, report it,
do not bend the test to fit.

## Gherkin

Optional. If the plan adopts a runner (cucumber, behave, pytest-bdd,
SpecFlow…), the scenarios in `spec.md` are copied verbatim into `.feature`
files under `tests/<context>/features/` and the step definitions obey every
rule above. If no runner, the shape above is enough. Do not add a runner for
its own sake.
~~~~

  — verify: `sed -n 2p .claude/skills/bdd/SKILL.md` prints `type: Skill`; `grep -q 'name: bdd' .claude/skills/bdd/SKILL.md`.

- [ ] **T311** · Create `.claude/skills/ddd/SKILL.md`:

~~~~markdown
---
type: Skill
name: ddd
description: Minimal Domain-Driven Design reference for this workflow — bounded contexts and the context map, scoped ubiquitous language, domain events as the published language, invariants. Use when dividing a product into contexts, deciding which context a slice belongs to, naming an event, defining an invariant, or when the words "domain", "bounded context", "aggregate", "ubiquitous language" or "context map" come up.
---

# DDD — the parts we use

The goal is code that stays organised, readable and changeable as slices
accumulate. Four ideas do that. The rest of DDD's vocabulary is not used
here; do not introduce it.

## 1. Bounded contexts

A context is an area of the product that owns one model and one vocabulary.
Inside it, a word means one thing. Across contexts, the same word may mean
different things, and that is fine — it is *why* they are separate.

Signs you are looking at two contexts: the same noun with different fields
or rules in two places; two groups of people who would describe the thing
differently; a change to one part that never requires a change to the other.

Signs you have over-split: contexts that always change together; a "context"
that is one table; events flowing in both directions between the same pair.

Every context has a **code root** and everything in it lives there. The
map is `docs/domain.md`. `scripts/check-contexts.sh` enforces the boundary.

**One slice, one context.** A request that spans two is either two slices or
an integration slice (its whole job is the event/interface between them).
Say which, in `grill`.

## 2. Ubiquitous language — scoped

`docs/glossary.md` has a Context column. The context's word is used in its
specs, code, tests and events, exactly. Not a synonym, not an abbreviation,
not the "technical" name. If the user says *reading*, the type is `Reading`,
the event is `ReadingRecorded`, the test says reading.

A word used across contexts unchanged is listed under Shared in the map.
Keep that list short; each entry is coupling.

## 3. Domain events — how contexts talk

Contexts do not import each other's internals. They communicate through
**events**: past-tense facts, named in the emitting context's language,
schema-first (engineering §8), carrying what the downstream needs and no
more.

`ReadingRecorded`, `InvoiceIssued`, `AccessRevoked`. Not `UpdateReading`,
not `ReadingDTO`, not a row.

The downstream context **translates** an incoming event into its own types
at its adapter — the anti-corruption layer — and never lets the upstream's
shape into its domain. When the upstream changes, only the adapter changes.

Synchronous interfaces are allowed where a request/response is genuinely
needed; they live under the owning context's `published/` and are also
schema-first. Prefer events.

## 4. Invariants

An invariant is a rule that must always hold inside a context: *a booking
never overlaps another for the same room*; *a ledger's entries always sum
to zero*. Each is:

- a row in `docs/domain.md › Invariants`, with the noun that guards it;
- an EARS ubiquitous requirement (`THE SYSTEM SHALL …`) in every slice that
  could touch it;
- a test that tries to break it (property-based where possible — `bdd`
  skill).

The noun that guards an invariant is what DDD calls an aggregate root: all
changes that could violate the rule go through it, in one transaction. We
name the rule and its guardian; we do not need the pattern's name.

## What we skip, and why

- **Entity vs value object** as a required classification. The typing
  preference — make illegal states unrepresentable, distinct types for
  distinct ids — gives the benefit without the taxonomy.
- **Repositories, factories, domain services, application services** as
  mandated layers. Ports & adapters (engineering §6) already says where IO
  goes; the plan chooses the rest per context.
- **Strategic pattern names** (Conformist, Customer/Supplier, Open Host,
  Shared Kernel, Published Language). The map records *direction* and
  *mechanism*, which is what an agent needs to act on.
- **Event-storming workshops.** `sdd-init` asks five questions instead.

If a situation seems to need one of these, it is a plan decision for the
user, not a default.
~~~~

  — verify: `grep -q 'name: ddd' .claude/skills/ddd/SKILL.md`

- [ ] **T312** · Create `scripts/check-scenarios.sh`, `chmod +x`:

~~~~bash
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
~~~~

  — verify: `bash -n scripts/check-scenarios.sh && ./scripts/check-scenarios.sh; true`

- [ ] **T313** · Commit: `feat(bdd): scenarios in specs, bdd and ddd skills, scenario coverage check`

### Phase R — Wire the skills

- [ ] **T314** · `.claude/skills/sdd-init/SKILL.md` — insert a new step after Step 3 (product brief) and renumber Steps 4–7 to 5–8:

~~~~markdown
## Step 4 — Domain discovery → `docs/domain.md`

Read the `ddd` skill. Then, from the product brief, propose a first cut of
bounded contexts and interrogate it, one question at a time, recommended
answer attached:

1. **Nouns.** List every noun in the brief. Group the ones that change
   together and are described by the same people. Each group is a candidate
   context. Ask: "Does *<noun>* mean the same thing everywhere, or does it
   mean something different to <group A> than to <group B>?" A different
   meaning is a context boundary.
2. **Verbs → events.** For each context, what happens that other parts of the
   product need to know about? Name each as a past-tense fact in that
   context's words. Ask: "When <event>, who needs to know, and what do they
   need from it?"
3. **Rules.** For each context: "What must never be true? What would be a
   bug in the data, not just in the code?" Each answer is an invariant.
4. **Roots.** Propose a code root per context (`src/<name>/`). Confirm.
5. **Shared.** Anything that genuinely must be identical across contexts.
   Push back on each one.

Write the file. Three to seven contexts is normal; one is fine for a small
product. Fill `title`, `description`, `generated.*` with `fm.py set`.

**Gate**: show it in full; *Approve* / *Revise* / *Merge two contexts* /
*Split one*. On approval `./scripts/approve.sh docs/domain.md approved`,
`./scripts/index.sh`, append decisions.

The roadmap (next step) tags every slice with its context, and the glossary
(after that) scopes every term to one.
~~~~

  Also in the (now) Step 5 roadmap: change the table instruction to `Propose a first cut of 3–8 slices, ordered, one-line outcome each, **the context each belongs to**, and the dependencies between them.` and add a question: `- Does any slice span two contexts? Then it is two slices, or an integration slice.` In the (now) Step 6 glossary: `For each, ask which context it belongs to and for the definition the *user* uses in that context.` Update the Step 8 commit message to `docs(init): product brief, engineering, domain, roadmap, glossary`.
  — verify: `grep -q 'Domain discovery' .claude/skills/sdd-init/SKILL.md && grep -q 'docs/domain.md' .claude/skills/sdd-init/SKILL.md`

- [ ] **T315** · `templates/roadmap-template.md` — change the table header to `| # | Slice | Context | Outcome (one line) | Depends on | Status | Spec |` and the two example rows to match (add a `\`<ctx>\`` column). Add `- resource: /docs/domain.md` to `sources`.
  — verify: `grep -q '| Context |' templates/roadmap-template.md`

- [ ] **T316** · `.claude/skills/grill/SKILL.md` — in `## What to grill on`, insert as the second item (after **Purpose**):

~~~~markdown
**Context** — Which bounded context in `docs/domain.md` owns this? Read the
map first; recommend one. If the honest answer is "two", say so: it is
either two slices or an integration slice whose only job is the event or
interface between them — ask which. Which nouns from the context's Owns
column does this touch? Which events does it emit or consume? Which
invariants could it violate?
~~~~

  In `## Output — intent.md`, add: `Set \`sdd_context\` on \`intent.md\` with \`fm.py set\` once the context is decided; \`new-feature.sh\` will not know it.`
  — verify: `grep -q 'sdd_context' .claude/skills/grill/SKILL.md`

- [ ] **T317** · `.claude/skills/sdd-specify/SKILL.md` — edits:
  (a) `## Before writing` add item 6: `6. Read \`docs/domain.md\` and the \`ddd\` and \`bdd\` skills. Copy \`sdd_context\` from \`intent.md\` to \`spec.md\` (\`fm.py set\`). Read the context's row in the map and its invariants.`
  (b) In `## Writing the spec`, after item 4 (Relationship to other slices) insert `5. **Domain** — context, nouns touched, events emitted/consumed, invariants preserved and introduced. Every invariant that this slice could violate becomes a ubiquitous requirement below.` and renumber the rest.
  (c) Change the Requirements item to: `**Requirements** — EARS, one ID each. For each one, immediately write its **scenarios**: Given / When / Then with real values, one per acceptance path *including the failure paths*, each with an ID \`REQ-00N/Sk\`. A requirement with no failure scenario needs a stated reason.`
  (d) In `## The discipline` add: `- **Scenarios are observable from outside the context.** If a Then can only be checked by looking at internal state, it is not a scenario — restate it in terms of what a caller sees.` and `- **Glossary words, in this context's meaning.**`
  (e) `## Gate` report list add: `- Context, and any invariant this slice introduces`.
  — verify: `grep -c 'scenario' .claude/skills/sdd-specify/SKILL.md` ≥ 3; `grep -q 'docs/domain.md' .claude/skills/sdd-specify/SKILL.md`.

- [ ] **T318** · `.claude/skills/ears/SKILL.md` — append before `## Provenance`:

~~~~markdown
## EARS and scenarios

EARS states the rule; a scenario is one concrete example that proves it.
Every requirement has at least one scenario, usually one per path:

```
WHEN a client submits credentials
THE SYSTEM SHALL validate them and return a signed session token

REQ-004/S1 — valid credentials produce a session
  Given user "ada" exists with password "correct-horse"
  When "ada" submits password "correct-horse" from 203.0.113.9
  Then the response is a session token valid for 7 days

REQ-004/S2 — fifth failure in 15 minutes is rate-limited
  Given four failed attempts from 203.0.113.9 in the last 14 minutes
  When a fifth attempt arrives from 203.0.113.9
  Then the response is 429 with Retry-After 60
```

Mapping: the EARS trigger (`WHEN`) is the scenario's **When**; the EARS
precondition (`WHILE`/`WHERE`/`IF`) is the **Given**; the `SHALL` clause is
the **Then**. Ubiquitous requirements (invariants) get a scenario per way the
rule could be broken. A scenario's Then is always observable from outside the
context — see the `bdd` skill.
~~~~

  — verify: `grep -q 'EARS and scenarios' .claude/skills/ears/SKILL.md`

- [ ] **T319** · `.claude/skills/sdd-plan/SKILL.md` — edits:
  (a) `## Before writing` add: `7. Read \`docs/domain.md\` and the \`ddd\` skill. The plan's Structure mirrors the slice's context root; anything other contexts may use goes under \`published/\`; consumed events are translated at an adapter.`
  (b) In `## Writing the plan`, after **Interfaces** add: `**Events** — every event this slice emits or consumes, with its schema path. Emitted events are named in this context's language, past tense, and their schema lives under \`published/\`. If a consumed event's shape leaks past the adapter into domain code, the plan is wrong.`
  (c) `## Gate` on-approval list add: `- if this slice introduces a context, event or invariant not yet in \`docs/domain.md\`, propose the map change as a gated edit (\`approve.sh docs/domain.md approved\` after the user agrees)`. And: `- tune \`scripts/check-contexts.sh\` (PUBLISHED, IMPORT_RE) to the chosen stack if needed`.
  — verify: `grep -q 'published/' .claude/skills/sdd-plan/SKILL.md && grep -q 'check-contexts' .claude/skills/sdd-plan/SKILL.md`

- [ ] **T320** · `.claude/skills/sdd-tasks/SKILL.md` — in `## Task anatomy`, change the **Steps** bullet to: `- **Steps** — 3–8, each 2–5 minutes, checkbox-numbered. TDD-shaped and scenario-driven: RED names the scenario ID (\`REQ-00N/Sk\`) and gives the actual test code, through the published interface (\`bdd\` skill) → run, expect *this* failure → GREEN → run, expect pass, suite green → REFACTOR.` In `## Self-review before the gate` add: `- **Scenario coverage** — every scenario ID in the spec appears in some task's RED step. \`./scripts/check-scenarios.sh specs/NNN-slug\` will report gaps once tests exist; for now, grep.`
  — verify: `grep -q 'REQ-00N/Sk' .claude/skills/sdd-tasks/SKILL.md`

- [ ] **T321** · `.claude/agents/task-reviewer.md` — in `## Stage 1 — Spec compliance`, replace the RED-step bullet with:

~~~~markdown
- The RED step: is there a test named after the cited scenario ID, and does
  it cite it verbatim? Would it fail without the change? If the test would
  pass against an empty implementation, it is not a test.
- **Implementation coupling** (`bdd` skill): does the test reach only the
  context's published interface and port fakes? A test that imports internal
  modules, patches inside the context, asserts on how something was called,
  or reads private state is **important** — the implementation could not be
  rewritten without editing it.
- **Boundary**: does the diff import another context's internals? Run
  `./scripts/check-contexts.sh`; a violation is **critical**.
~~~~

  — verify: `grep -q 'check-contexts' .claude/agents/task-reviewer.md && grep -q 'Implementation coupling' .claude/agents/task-reviewer.md`

- [ ] **T322** · `.claude/agents/implementer.md` — in the intro, change `You have the \`tdd\` and \`debugging\` skills.` to `You have the \`tdd\`, \`bdd\` and \`debugging\` skills.` and add to `## Procedure` step 2: `The RED test is named after the scenario ID in the step and drives the context through its published interface only (\`bdd\`).` Add to `## Never`: `- Import another context's internals. Only its \`published/\` interface or its events.`
  — verify: `grep -c 'bdd' .claude/agents/implementer.md` ≥ 2

- [ ] **T323** · `REVIEW.md` — pass 1 becomes:

~~~~markdown
1. **Spec compliance** — every `REQ-` in `spec.md`: implemented; every
   scenario `REQ-N/Sk` has a test citing it verbatim (`scripts/check-scenarios.sh`);
   every scenario's Then holds with the exact values. A test coupled to
   implementation (imports internals, patches inside the context, asserts on
   calls, reads private state) does not count as covering its scenario.
~~~~

  Add pass 3b after plan conformance:

~~~~markdown
3b. **Domain boundaries** — `scripts/check-contexts.sh` clean; emitted events
   are past-tense, in this context's language, schema-first under
   `published/`; consumed events are translated at an adapter and their shape
   does not appear in domain code; every invariant in `docs/domain.md` that
   this slice could touch has a test that tries to break it. A boundary
   violation is critical.
~~~~

  `REVIEW.md` is the user's file and the `guard-paths` hook blocks the Edit/Write tools on it. This plan is the user's own instruction to change it, so: show the two blocks above, get an explicit yes in conversation, then apply the edit with a short `python3` read-modify-write run through Bash. Do not touch the hook.
  — verify: `grep -q 'check-scenarios' REVIEW.md && grep -q '3b. \*\*Domain boundaries' REVIEW.md`

- [ ] **T324** · `.claude/skills/sdd-converge/SKILL.md` — in `## How this phase runs` step 1, add to the reviewer instruction: `…apply \`REVIEW.md\`, run \`./scripts/check-scenarios.sh specs/<slice>\` and \`./scripts/check-contexts.sh\`, and write its report to…`. In `## Checks` change the shape line to `spec compliance (scenario coverage) → constitution → engineering preferences → plan conformance → domain boundaries → bugs → security → scope → hygiene → notes fold-back`. In `## Report format` add a table after the requirement table:

~~~~markdown
| Scenario | Test | Through public interface? |
|---|---|---|
| REQ-001/S1 | ✅ tests/auth/scenarios/test_login.py::test_REQ_001_S1_… | ✅ |
| REQ-001/S2 | ❌ none | — |

Domain boundaries: `check-contexts.sh` ✅ / ❌ (findings below)
~~~~

  — verify: `grep -q 'check-scenarios' .claude/skills/sdd-converge/SKILL.md && grep -q 'check-contexts' .claude/skills/sdd-converge/SKILL.md`

- [ ] **T325** · `.claude/agents/reviewer.md` — step 3 add: `Run \`./scripts/check-scenarios.sh specs/<slice>\` and \`./scripts/check-contexts.sh\`; paste both outputs into the report.` Step 2 add `docs/domain.md` to the files read.
  — verify: `grep -q 'check-scenarios' .claude/agents/reviewer.md`

- [ ] **T326** · `templates/engineering-template.md` — two defaults tightened:
  §6 Architecture default becomes: `**Default:** bounded contexts from \`docs/domain.md\`, each under its own code root with a \`published/\` interface; vertical slices inside a context, not horizontal layers across the product. Ports and adapters at every IO boundary (database, network, filesystem, clock, randomness, other contexts) so the domain can be tested with fakes. No framework types in domain code. Contexts communicate by past-tense, schema-first events, translated at the consumer's adapter.`
  §7 Testing default becomes: `**Default:** TDD — no production code without a failing test first (\`tdd\` skill). Tests are the spec's scenarios (\`bdd\` skill): one per Given/When/Then, named after its ID, exercising the context through its published interface only, so the implementation can be rewritten without touching the test. Fakes at ports (in-memory repository, settable clock), never mocks asserting on internal calls. Property-based tests for invariants. Coverage is scenario traceability, not a percentage.`
  — verify: `grep -q 'published/' templates/engineering-template.md && grep -q 'bdd' templates/engineering-template.md`

- [ ] **T327** · Commit: `feat(ddd,bdd): skills, agents and review policy are context- and scenario-aware`

### Phase S — Checks, docs, guide

- [ ] **T328** · `scripts/check-specs.sh` — edits:
  (a) After the "Engineering preferences" block add:
  ```bash
  echo; echo "Domain map"
  if [[ ! -f docs/domain.md ]]; then warn "docs/domain.md missing — /sdd-init step 4"
  elif [[ "$(./scripts/fm.py get docs/domain.md sdd_phase 2>/dev/null)" != "approved" ]]; then warn "docs/domain.md is not approved"
  else echo "  ✅ approved ($(awk -F'|' '/^## Contexts/{p=1;next} p&&/^## /{exit} p&&NF>6&&$2!~/Context|---/{n++} END{print n+0}' docs/domain.md) contexts)"; fi
  ```
  (b) Inside the per-slice loop, after the roadmap check, add:
  ```bash
  ctx=$(./scripts/fm.py get "$d/spec.md" sdd_context 2>/dev/null || echo "")
  if [[ -z "$ctx" || "$ctx" == "<context>" ]]; then
    [[ "$status" == "draft" ]] || warn "spec has no sdd_context"
  elif [[ -f docs/domain.md ]] && ! grep -qE "^\| *\`?$ctx\`? *\|" docs/domain.md; then
    bad "sdd_context '$ctx' is not a context in docs/domain.md"
  fi
  ```
  (c) After the requirement count, for non-untouched specs: 
  ```bash
  for r in $(grep -oE '^### REQ-[0-9]+' "$d/spec.md" | sed 's/### //'); do
    grep -qE "$r/S[0-9]+" "$d/spec.md" || warn "$r has no scenario"
  done
  ```
  — verify: `bash -n scripts/check-specs.sh && ./scripts/check-specs.sh; true` shows a `Domain map` section.

- [ ] **T329** · `docs/okf.md` — add to the Types table: `| \`docs/domain.md\` | \`Domain Map\` | \`draft \| approved\` |`. Add to Common fields: `| \`sdd_context\` | The bounded context (from \`docs/domain.md\`) a slice artefact belongs to. |`.
  — verify: `grep -q 'Domain Map' docs/okf.md`

- [ ] **T330** · `AGENTS.md` — `## Where things are` add after the glossary line: `- \`docs/domain.md\` — the bounded contexts, their code roots, the events between them, the invariants. A slice belongs to one. Code never crosses a context except through \`published/\`.` `## Never` add: `- Import another context's internals; only its \`published/\` interface or its events. \`scripts/check-contexts.sh\` fails otherwise.` and `- Write a test that reaches inside the context. Tests go through the published interface (\`bdd\` skill).`
  — verify: `grep -c 'published/' AGENTS.md` ≥ 2

- [ ] **T331** · `docs/sdd-guide.md` — (a) `## What is here`: add `docs/domain.md`, `scripts/check-contexts.sh`, `scripts/check-scenarios.sh` lines; (b) `## The skills` table: add `ddd` and `bdd` rows; (c) new section before `## Why it is shaped this way`:

~~~~markdown
## Domains and behaviours

Two disciplines run through every phase, deliberately kept to their most
useful parts.

**Domain-driven design — four ideas, no vocabulary tax.** During `sdd-init`
the product is divided into **bounded contexts** (`docs/domain.md`): named
areas that each own one model and one vocabulary, with a code root each.
Every slice belongs to exactly one. Contexts talk through **past-tense,
schema-first events** and never by importing each other's internals —
`scripts/check-contexts.sh` fails the build if they do. The **glossary is
scoped per context**, so the same word can mean two things in two places
and the code in each uses its own. Each context lists its **invariants** —
the rules that must never be false — and every one becomes a requirement
and a test that tries to break it. Entities vs value objects, repositories,
strategic-pattern names, event-storming workshops: skipped. The `ddd` skill
says why.

**Behaviour-driven tests — the spec's scenarios, executable.** Every
requirement in a spec carries Given/When/Then **scenarios** with real
values, one per path including failures, each with an ID like
`REQ-004/S2`. A test is one scenario, named after it, driving the context
through its **published interface only**. The litmus, from the `bdd` skill:
*could the implementation be rewritten from scratch and this test still
pass unedited?* A test that imports internals, patches inside the context,
or asserts on how something was called fails review. Fakes live at ports
(an in-memory repository, a settable clock); mocks that verify calls are
forbidden. `scripts/check-scenarios.sh` is the coverage metric — every
scenario has a test — and replaces line coverage. Gherkin runners are
optional; the discipline is not.
~~~~

  (d) Credits: add `- Bounded contexts, ubiquitous language, domain events, invariants: Evans, *Domain-Driven Design* (2003); Vernon, *Implementing DDD* (2013). Applied to agent codebases per [Golovko, From Prompt Spaghetti to Bounded Contexts](https://gitnation.com/contents/from-prompt-spaghetti-to-bounded-contexts-ddd-for-agentic-codebases).` and `- Given/When/Then scenarios: North, *Introducing BDD* (2006).`
  — verify: `grep -q 'Domains and behaviours' docs/sdd-guide.md`

- [ ] **T332** · `CLAUDE.md` — no change needed. Confirm `grep -c '' CLAUDE.md` is unchanged.

- [ ] **T333** · Commit: `docs(ddd,bdd): guide, okf types, AGENTS.md, check-specs`

### Phase T — Verify

- [ ] **T334** · Frontmatter check — 16 skills + 3 agents = **19** `ok` lines:
  ```bash
  for f in .claude/skills/*/SKILL.md .claude/agents/*.md; do
    n=$(sed -n 's/^name: //p' "$f" | head -1); ty=$(sed -n 's/^type: //p' "$f" | head -1)
    dir=$(basename "$(dirname "$f")"); base=$(basename "$f" .md)
    { [ "$n" = "$dir" ] || [ "$n" = "$base" ]; } && [ -n "$ty" ] && echo "ok $f" || echo "FAIL $f"
  done | grep -c '^ok'
  ```

- [ ] **T335** · Functional smoke:
  ```bash
  ./scripts/new-feature.sh smoke >/dev/null
  ./scripts/fm.py set specs/001-smoke/spec.md sdd_context readings
  ./scripts/fm.py check specs/001-smoke/spec.md
  grep -c 'REQ-001/S' specs/001-smoke/spec.md             # expect 2
  sed -e 's/conversation:YYYY-MM-DD/conversation:2026-01-01/' templates/domain-template.md > docs/domain.md
  ./scripts/check-contexts.sh                              # "no contexts declared" (template rows are placeholders)
  ./scripts/check-scenarios.sh specs/001-smoke             # scenarios listed, "no test expected" (draft)
  ./scripts/check-specs.sh; true                           # shows Domain map section
  rm -rf specs/001-smoke docs/domain.md; ./scripts/index.sh >/dev/null
  ```
  — verify: each command behaves as its comment says; no bash errors.

- [ ] **T336** · OKF sweep: `for f in $(find docs specs memory templates .claude -name '*.md' ! -name index.md ! -name log.md); do ./scripts/fm.py check "$f"; done | grep -c FAIL` prints `0`.

- [ ] **T337** · `git rm docs/upgrade-plan-4.md`; commit: `chore(sdd): v4 — ddd and bdd, verified`.

## Deferred

- A language-specific `check-contexts` (import graph via the real parser)
  once the first project picks a stack; the grep heuristic is tuned in
  `/sdd-plan` until then.
- Gherkin `.feature` generation from `spec.md` — only if a project adopts
  a runner.
- Context-level `AGENTS.md` files under each `src/<context>/` (the
  nested-AGENTS.md pattern) — worth it once a project has three or more
  contexts.
- Event schema registry checks (backward-compatibility of published
  events) — belongs with the first project's CI, not the template.
