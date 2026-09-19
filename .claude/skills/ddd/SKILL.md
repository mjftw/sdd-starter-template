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
