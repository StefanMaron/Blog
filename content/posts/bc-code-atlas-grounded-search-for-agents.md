---
title: "Introducing bc-code-atlas: Real BC Source for Coding Agents, Not a Guess"
description: "An MCP server that gives an AI coding agent — or you — grounded access to the actual Business Central Base Application source, across versions and countries, with every result verified against the real file."
date: 2026-08-10T07:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'AI', 'MCP', 'Open Source', 'DevOps']
---

Ask an AI coding agent where BC validates a sales order before posting, and it will confidently give you a procedure name. Sometimes that name is real. Sometimes it's a plausible-sounding hallucination assembled from training data that's a few versions stale. Either way, the agent isn't looking anything up — it's pattern-matching against what it remembers, and it has no way to tell you which one it's doing.

I've been building [bc-code-atlas](https://github.com/StefanMaron/bc-code-atlas) to fix that, and I'm announcing it publicly today.

## What it is

bc-code-atlas is an MCP server that gives an agent — or a human, through the same tools — grounded access to BC's actual Base Application source, across versions and countries. The core rule behind it: every result has to be verifiable against the real file. Not "trust the index." Read the index, then check.

There are two ways to find things. Semantic search ranks by meaning, through embeddings, for when you don't know the exact name of what you're looking for. An exact structural graph gives you real `calls` / `subscribes` / `extends` edges, parsed directly from AL source rather than inferred from text similarity, for when you need to know precisely what calls what. On top of both, a set of exact-source tools — `bcatlas_get_procedure_body`, `bcatlas_get_object_source` — always read straight from the real file, so a search result is a pointer you can verify, not a claim you have to take on faith.

It also supports diffing a symbol's history across BC versions and country variants — useful if you're trying to find out what actually changed between 28.1 and 28.2, instead of guessing from a changelog.

## A concrete example

The exact-source lookup is the easy part to demonstrate — it's just reading a file. The part actually worth showing is what semantic search gives back, so here's real output, run against the live public instance while writing this post:

```
bcatlas_search(query="check available inventory quantity before shipping a sales line", limit=5)
```

None of those words are a procedure name. Here's what came back, unedited:

1. **`SalesLine.Table.al` — `CheckWarehouseForQtyToShip`** (score 0.933) — the actual controlling procedure: checks whether the item is inventoriable, whether the location requires shipment, and calls into warehouse verification before a quantity-to-ship can go through.
2. **`SalesLineReserve.Codeunit.al` — `VerifyPickedQtyReservToInventory`** (score 0.922) — reservation-side verification against warehouse shipment lines and picked quantity.
3. **`SalesLine.Table.al` — `CanShipQty`** (score 0.918) — a boolean check comparing quantity-to-ship against outstanding quantity and sign consistency.
4. **`SalesLine.Table.al` — `IsShipment`** (score 0.914) — a one-line helper checking whether a signed base quantity represents a shipment.
5. A Microsoft Learn doc on assemble-to-order quantity rules (score 0.910) — indexed and ranked right alongside the AL source, not kept in a separate system.

Nothing in the query said "CheckWarehouseForQtyToShip" or "CanShipQty" — those names came from ranking by what the code actually does, not by matching words. That's the difference between this and a `grep` across the Base App: you can describe the behavior you're looking for in plain language and get the procedures that actually implement it, code and documentation together, ranked by relevance. From there, pulling the exact current source of any of those hits — `bcatlas_get_procedure_body(label="...")` — is the mechanical last step, reading straight from the real file rather than the index.

## Try it

**Hosted, no setup:** point an MCP client at `https://bc-code-atlas.stefanmaron.dev/mcp`. There's also a lightweight CLI-skill alternative under `skills/bc-code-atlas-cli/` in the repo, if you'd rather not load MCP tool schemas into an agent's context at all.

**Self-hosting:** `git clone --recurse-submodules`, `uv sync` per subproject, point it at a local sentence-transformers embedding model, index with `ccc index`, and run the five servers (search, graph, registry, build, aggregator) behind a local aggregator on port 8800.

## How it's built

bc-code-atlas doesn't parse AL from scratch. It's built on [graphify-al](https://github.com/ChristianHovenbitzer/graphify-al), [Christian Hovenbitzer](https://github.com/ChristianHovenbitzer)'s fork of the general codebase-to-knowledge-graph tool graphify, which is the one that actually added AL language support — objects, procedures, cross-object calls, event subscriptions, extension targets — through `tree-sitter-al`. I maintain a downstream fork of that with a handful of fixes specific to bc-code-atlas's needs, but the AL support itself is Christian's work. Thank you for building it.

The indexed source spans roughly 51 country variants across around 10-11 major BC versions. One thing worth mentioning about that scale: the World and US country variants of BC 28 share about 87% identical files at the same path, despite their two git branches sharing zero commit history. That's not something you'd know from looking at branch metadata — only from actually comparing the content, which is exactly the kind of thing this project exists to make easy to check instead of assume.

## What it's good for right now, and what's still rough

It's already useful for exactly the case at the top of this post: point an agent at it before it writes AL code that touches Base Application logic, and it can look up the real procedure instead of guessing one. The version and country diffing is useful on its own even without an agent involved, if you're trying to understand what changed in a specific area of the Base App.

I want to be upfront about where it's still early. There's no authentication on the public instance beyond an optional API key flag, so treat it as a read-only public service, not something to point sensitive queries at. It's had real production issues already — a restart bug once left search silently unavailable for about two days before anyone noticed, which is now documented and partly addressed, but the fix hasn't been tested under every failure mode yet. This is a young project, not a finished product, and I'd rather say that plainly than have you discover it through a failure.

## Try it, and tell me what's missing

If you're working with BC/AL and use an AI coding agent, or if you just want a faster way to check what a piece of Base Application code actually does across versions, give it a try. Issues and pull requests are open on the [repo](https://github.com/StefanMaron/bc-code-atlas) — coverage gaps, wrong results, anything that doesn't match real BC behavior is exactly what I want to hear about.
