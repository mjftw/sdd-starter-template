---
type: Decision Log
title: Decisions
description: Append-only log of every decision the user has made, read by every phase before asking anything.
resource: /docs/decisions.md
status: stable
tags: [sdd, decisions]
---

# Decisions

> Append-only. One line per decision the user has made, anywhere in the
> workflow. Read by every phase before asking anything. A decision here is
> never re-asked by an agent; only the user reopens it, and the reopening is
> itself a new line.
>
> Format: `YYYY-MM-DD · <where: init | constitution | engineering | NNN-slug> · <decision> · <why, one line>`

