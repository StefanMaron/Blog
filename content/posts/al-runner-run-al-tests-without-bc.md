---
title: "AL Runner: Run AL Unit Tests Without a BC Service Tier"
description: "A standalone CLI tool that transpiles your AL source to C#, rewrites BC runtime types to in-memory mocks, and executes your test codeunits in seconds — no container, no SQL Server, no license required."
date: 2026-04-24T07:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'Unit Testing', 'AI', 'Pipelines', 'Open Source']
---

[![BusinessCentral.AL.Runner on GitHub — Test Matrix passing, NuGet v1.0.20](/images/al-runner-run-al-tests-without-bc/01-github-repo-header.png)](https://github.com/StefanMaron/BusinessCentral.AL.Runner)

One Sunday afternoon in March I was playing with my daughter when a thought struck me out of nowhere: what if we could run AL code directly? Not through the service tier, not through a container — just... run it. I fired up the PC, set Claude Code loose on the investigation, and went back to playing. By the time we were done, there were some very interesting findings waiting for me.

It turned out the BC compiler, when used directly, exposes public API to transpile AL into C# representation. Not the compiler binary you call from VS Code — the libraries behind it. `Microsoft.Dynamics.Nav.CodeAnalysis.Compilation.Emit()`. You can call it yourself, get C# out, no service tier involved.

That kept me thinking: what if we fix the loose ends of that C# output and just execute it?

A few weeks later, [BusinessCentral.AL.Runner](https://github.com/StefanMaron/BusinessCentral.AL.Runner) exists.

## What it does

AL Runner is a CLI tool that runs your AL unit tests without a BC service tier, Docker container, or SQL Server. It works like this:

```
AL Source (.al files on disk)
  │  BC Compilation.Emit()     → transpile AL to C#
  │  RoslynRewriter            → replace BC runtime types with in-memory mocks
  │  Roslyn in-memory compile  → compile against BC Service Tier DLLs
  │  Executor                  → discover [Test] methods, run, report results
Results in seconds
```

**Stage 1** calls the BC compiler's public API to convert your AL objects — tables, codeunits, enums, queries, report triggers — into C# classes.

**Stage 2** rewrites that C# with a `CSharpSyntaxRewriter`. BC runtime types (`NavRecordHandle`, etc.) get replaced with mock implementations that work entirely in memory.

**Stage 3** compiles everything with Roslyn in-memory. The BC Service Tier DLLs it needs (~11 MB) are downloaded automatically on first run from the BC artifact CDN. Not the full 1.2 GB artifact — just what's needed.

**Stage 4** discovers test codeunits (`Subtype = Test`), resets the in-memory table store between tests, runs each `[Test]` procedure via reflection, and reports pass/fail/error.

## Installing it

```bash
dotnet tool install --global MSDyn365BC.AL.Runner
```

On first run it downloads the AL compiler (~57 MB from NuGet) and the BC Service Tier DLLs (~11 MB). No manual setup. Works on Windows, Linux, and macOS.

## Running it

```bash
# Run all test codeunits in ./src and ./test
al-runner ./src ./test

# With .alpackages for symbol resolution
al-runner --packages .alpackages ./src ./test

# Run a single test by name
al-runner --run TestMyProcedure ./src ./test

# CI output
al-runner --output-junit results.xml ./src ./test
```

## Why this matters

Any pipeline that spins up a BC container starts with at least 15 minutes of overhead — pulling the image, starting the service tier, waiting for it to be ready. That's before a single test runs. A typical full pipeline with BCAL GitHub Actions takes 20-30 minutes.

AL Runner drops that overhead entirely. Transpilation, in-memory compilation, and test execution all happen in seconds. For pure unit tests with no heavy dependency calls, individual test procedures run in milliseconds.

To give you a concrete sense of scale: the AL Runner repository ships with **3,400 `[Test]` procedures** spread across 266+ self-contained AL scenarios — record operations, events, interfaces, queries, collections, mocks, stubs, and more. This isn't a claim that every AL feature is covered; it's an ever-growing set that covers everything touched so far, and grows with every gap that gets closed. You can run all of them yourself:

```bash
git clone https://github.com/StefanMaron/BusinessCentral.AL.Runner
al-runner ./tests/bucket-1
al-runner ./tests/bucket-2
```

They complete in about 30 seconds.

That's also the answer to the obvious trust question.

## Can we trust it to behave like real BC?

This is probably the first thing you're thinking: AL Runner re-implements and mocks a significant amount of what the service tier normally does. How do we know it behaves correctly?

The rule I set for this project from day one: **we have to prove it works, otherwise the assumption is it doesn't.** Those 3,400 test cases aren't just coverage metrics — they're the ongoing proof. Every push runs the full suite against a matrix of BC versions (currently BC 26 through BC 28) via GitHub Actions. If a rewrite rule breaks something subtle, the tests catch it.

Check the [Test Matrix badge](https://github.com/StefanMaron/BusinessCentral.AL.Runner/actions/workflows/test-matrix.yml) on the repository if you want to verify the current state yourself.

## Two use cases worth calling out

### Fast CI pre-check

There are a few ways to fit this into a pipeline. The simplest is as a pre-check — AL Runner runs first, and the full pipeline only continues if it passes:

```
Pull Request
  │
al-runner (seconds) ── catches AL logic failures fast
  │ (only if al-runner passes)
Full BC pipeline (45+ min) ── full fidelity
```

But you could also go further: run AL Runner on every pull request for fast feedback, and reserve the full pipeline for merges to main only. That way developers get results in seconds on every PR, and the expensive container-based run only happens once before anything reaches production. Fast iteration where it counts, full fidelity where it matters.

### AI coding agents

This is the use case I'm most excited about. AL Runner is a pure CLI tool — cross-platform, no GUI, machine-readable output. That makes it a natural fit for coding agents.

The pattern I have in mind: the agent writes a test first, runs `al-runner`, verifies it fails for the right reason, implements the solution, runs `al-runner` again, verifies it passes. Test-driven development that the agent can execute and verify in its own loop — without waiting for a container or a human to check results.

To make this easier, the runner includes a built-in guide accessible via `--guide` — a comprehensive prompt-ready reference covering how to write AL tests that work with the runner: the stubbing model, interface injection patterns, what to avoid. But in practice, you don't need to think about this at all. The `--help` output mentions it explicitly, and any coding agent worth its salt runs `-h` on any CLI tool it discovers. From experience, agents pick up the guide immediately after reading the help and load it into their context automatically. Just tell the agent to use AL Runner — it figures out the rest.

## Working with dependencies

The trickiest part of running AL without a service tier is dependencies. When your code calls into the Base Application — `TypeHelper`, `RestClient`, anything in an `.app` file — AL Runner can't execute that code. It only runs your `.al` source files. Dependencies are used for symbol resolution (so your code compiles) but not executed.

You have three options:

**Auto-stubs (default):** AL Runner automatically generates empty shells for any dependency codeunit your code references. Methods exist and return default values (`0`, `''`, `false`). If your test doesn't depend on what those methods return, this is fine.

**Hand-written stubs (`--stubs`):** Generate scaffold stubs from your packages and fill in controlled return values:

```bash
# Generate stub scaffolds
al-runner --generate-stubs .alpackages ./stubs ./src ./test

# Edit the stubs, then run with them
al-runner --stubs ./stubs --packages .alpackages ./src ./test
```

This is also how you implement proper dependency injection in tests — stubs can contain any AL object, including complete replacement implementations of dependency codeunits.

**Compiled dependency DLLs (`--compile-dep`):** If you have the AL source for a dependency and want real behavior (say, test library codeunits), compile it to a rewritten DLL:

```bash
# Compile a dependency source to a DLL
al-runner --compile-dep ./dependency-source ./deps --packages .alpackages

# Run tests with it
al-runner --dep-dlls ./deps --packages .alpackages ./src ./test
```

This executes the dependency code exactly as it would on the service tier.

## What's supported

The goal is that any AL object should compile and run without modification — codeunits, tables, enums, interfaces, queries, reports, page extensions. Some edge cases (like background sessions) aren't there yet, but the scope keeps expanding. That means:

- Variables, procedures, parameters by value and by ref, return values, control flow, `asserterror`, error handling
- Enums, interfaces, arrays, `List<T>`, `Dictionary<TKey, TValue>`, `TextBuilder`, temporary tables
- Record operations: `Insert`, `Modify`, `Delete`, `Get`, `Find`, `FindSet`, `SetRange`, `SetFilter`, `SetCurrentKey`, `CalcFields`, `CalcSums`, `Validate`, field triggers, composite and secondary keys
- `RecordRef`/`FieldRef`, `TestPage`, `Notification`, JSON types, `BigText`, mock `HttpClient`, `InStream`/`OutStream`, `Media`, `IsolatedStorage`, `TaskScheduler`, `DataTransfer`
- Event subscribers (integration and manual events, with `--init-events`)
- Single-dataitem queries

**What doesn't work** (and by design can't without a real service tier):

- Code inside `.app` packages — stubs or `--compile-dep` required
- Transaction semantics — `Commit()` and `Rollback()` are no-ops
- Parallel sessions — `StartSession` runs inline
- UI rendering — page layout, field visibility
- Multi-dataitem queries with JOINs
- Real HTTP I/O — inject via interface instead
- XmlPort `Import()`/`Export()`

The [limitations doc](https://github.com/StefanMaron/BusinessCentral.AL.Runner/blob/main/docs/limitations.md) has the full breakdown with workarounds.

## Try it on your own code

The project is at a point where I'm comfortable with more people running it. The best thing you can do right now — even if you don't have tests — is point it at a project and see if it compiles:

```bash
al-runner --packages .alpackages ./src
```

If something breaks, the runner will ask whether you want to send the details to telemetry. One keypress. It doesn't send usage data — just the error details needed to create a GitHub issue automatically. That feedback loop is how I close the remaining gaps. The more real-world AL code this runs against, the more robust it becomes.

If you'd rather go a step further: the contribution model is designed to be agent-friendly. Every gap in the runner can be expressed as a failing AL test case. Add a small `src/` + `test/` folder to the `tests/` directory with an AL snippet that demonstrates what doesn't work, open a pull request, and that's already the hardest part done. From there, a coding agent — Claude Code, GitHub Copilot, whatever you prefer — can look at the existing test structure, understand the pattern from the hundreds of examples already there, and implement the fix. I built the entire runner this way. The agent prompts I used are all in the repository. Give any coding agent a failing AL snippet, point it at the runner, and ask it to fix and PR the change. It works.

## Thank you

At some point I took a more structured approach to closing gaps. I extracted the full language surface from the BC DLLs and produced a report of roughly 1,400 missing procedures, overloads, and object features — a backlog too large to work through alone, especially after already burning through a significant amount of AI coding tokens getting the runner to where it was.

[Steve Endow](https://github.com/steveendow), [Brad Prendergast](https://github.com/dvlprlife), and [Jeremy Vyska](https://github.com/JeremyVyska) volunteered to donate tokens to keep the work moving. What followed was a proper multi-agent development sprint: an orchestrator agent running on a loop, pulling from the gaps document, creating GitHub issues, labelling them `status: ready`, and reviewing and merging pull requests as they came in. Each contributor then spawned multiple implementation agents in parallel — at peak, up to nine agents working simultaneously across the three of them, each picking up a `status: ready` issue, implementing the fix, writing the test, and opening a PR.

The agent prompts that drove all of this are in the repository under [`docs/agent-prompts/`](https://github.com/StefanMaron/BusinessCentral.AL.Runner/tree/main/docs/agent-prompts) — one for the orchestrator, one for implementation agents. If you want to contribute at scale, that's the playbook.

By the time the sprint wound down, Steve had 149 commits in the repo, Jeremy 84, and Brad 76. A huge chunk of AL Runner's current coverage exists because of their time and generosity. Thank you.

[SShadowS](https://github.com/SShadowS), [Flemming Bakkensen](https://github.com/FBakkensen), and [Volodymyr Dvernytskyi](https://github.com/Drakonian) also contributed — equally appreciated.

## What's next

There are two things worth mentioning.

**The DAP debugger** — AL Runner already includes an experimental Debug Adapter Protocol server. Set breakpoints in your AL source, inspect variable values during test execution, no service tier needed. It works by intercepting the `StmtHit(N)` calls the BC compiler emits at every statement. The implementation is still rough and needs more work before I'd call it production-ready, but the architecture is there.

**AL Mutations** — a mutation testing tool for AL that depends heavily on fast test execution. The idea: introduce small deliberate code changes (flip `>` to `>=`, comment out a `Modify()` call), run your tests, see which mutations your tests catch and which survive. A mutation that survives is a test gap. That project is [BusinessCentral.AL.Mutations](https://github.com/StefanMaron/BusinessCentral.AL.Mutations) — a topic for its own post.

**ALchemist** — built on AL Runner by [SShadowS](https://github.com/SShadowS), this VS Code extension brings live code execution to AL development. Think Quokka.js, but for AL: `Message()` output appears as inline ghost text next to your code, loop iterations show all variable values, and tests run directly in VS Code's Test Explorer — no container, no deploy cycle. AL Runner is the execution engine under the hood. Check it out at [github.com/SShadowS/ALchemist](https://github.com/SShadowS/ALchemist).
