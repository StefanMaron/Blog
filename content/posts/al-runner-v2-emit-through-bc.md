---
title: "AL Runner v2: What Feedback Told Me v1 Was Missing"
description: "v1 worked for the use cases it was built for. Companies actually using it told me that wasn't enough — most real extensions can't be unit tested at all without running against real Microsoft or ISV code. That feedback drove a clean v2 cut. It also changed how the runner fails: anything it can't support now throws loudly instead of quietly passing."
date: 2026-08-10T07:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'AL Runner', 'Testing', 'Open Source']
---

Last time I wrote about [AL Runner](https://github.com/StefanMaron/BusinessCentral.AL.Runner), it ran your AL unit tests without a service tier by transpiling AL to C#, renaming BC's runtime types (`NavRecord` became `MockRecord`, and so on), and stubbing out anything it didn't recognize. It worked. 3,400 tests passed.

Then the feedback started coming in from companies actually trying to use it, and it was consistent: the runner does what it says it does, for the use cases described. But most real-world extensions aren't unit-testable in that narrow sense at all. They call into Microsoft's Base Application, or into another vendor's ISV app, and if the runner can't execute that dependency's actual code, all it can offer is a stub that returns default values. For a huge share of real AL code, that's not a test — it's a test of your mocks. Without a way to run genuine integration tests against real Microsoft or third-party code, the tool wasn't usable for what people actually needed.

That's what sent me looking at the architecture again, not a performance number. It's why v2 is a clean cut rather than an incremental change on top of v1.

## What v1 actually got wrong

v1's whole approach was: take BC's real types, rename them, replace their guts with in-memory mocks, and hope every dependency your code touches is either your own source or something the stub generator can fake convincingly. That's why the previous post's `--extract-deps` existed — it sliced out just enough of a dependency's surface to keep the renamed-type trick working.

But a renamed type can never link against a real Microsoft or ISV-compiled DLL. The identity is gone the moment you rename it. Every dependency either had to be recompiled from source through the same rewriter, or stubbed. There was no path to "just load the real thing" — which is exactly the path the feedback said people needed.

The fix: don't rename BC's types at all. Compile AL through BC's own compiler, the same way the real service tier does, and leave dependency DLLs completely untouched. Only a small, low-level part of the engine gets patched — the part that routes database and session operations to an in-memory store instead of SQL Server. Everything else — your code, Microsoft's code, an ISV's code — runs unmodified.

That's the change that actually matters here: v2 can run against real dependency code, which means it can do integration testing, not just unit testing against a mock. That's v2.

Worth saying plainly, since it's easy to assume a rewrite means a speedup: v2 is not simply "faster than v1." Loading and linking real dependency code has a real cost that stubbing it out never did, so for a purely isolated unit test with no real dependencies, v2 can come out slower than v1 was. That's an accepted tradeoff, not an oversight. The entire point of v2 was to make the tests that v1 literally could not run, runnable at all — even if that means some tests that already worked fine now take longer.

## The cutover

`AL Runner v2: full architecture cutover` shipped as v2.0.0 on 2026-08-05. `--extract-deps`, the in-tree stub generator, and the old type-rename step are all gone — the full flag-compatibility mapping is in [`docs/v1-to-v2-migration.md`](https://github.com/StefanMaron/BusinessCentral.AL.Runner/blob/main/docs/v1-to-v2-migration.md) if you're upgrading a v1 setup.

It didn't pass on the first try. Cold CI runs needed the full service-tier DLL set — 250-500MB, not just the small subset v1 got away with — before the test suite passed cleanly. Two follow-up fixes later, it did.

From there, releases followed quickly: v2.0.0 → v2.0.1 → v2.1.0 → v2.1.1, all inside four days. Real Windows support shipped, verified on an actual Windows 11 VM rather than assumed. A query bug that silently corrupted filter-only columns in multi-table queries got fixed. `--auto-provision` now also fetches the Microsoft test toolkit, not just the platform apps, so a clean cache is runnable with zero manual steps.

By 2026-08-10, the language-behavior test suite was at 1,904/1,904 passing, alongside 373/373 unit tests and 114/114 runner-specific tests.

## It fails loudly instead of failing silently

This is the part I think matters more than the architecture change itself, and it's easy to miss if you're only reading the version-number history.

v1 would sometimes do something you didn't ask it to and not tell you: hit a surface it didn't support, fall back to a stub, and let your test pass anyway — green, but for the wrong reason. v2 has a deliberate rule for this: anything the runner cannot faithfully support throws immediately, with a message that names the exact API and the reason it's unsupported. That exception is not built on any BC exception type, on purpose — so AL's `asserterror` cannot catch and swallow it. If your test exercises something out of the runner's scope, the test fails. It cannot quietly pass.

There's also a real distinction encoded in that error: "permanently out of scope," with a citation to the specific line in the docs explaining why, versus "in scope, just not built yet." Either way, you get a clear, grep-able message telling you exactly what happened and where to read more, instead of a wrong result you'd only catch by noticing your test was too easy to pass.

Report rendering is the clearest example right now. The runner executes `Report.SaveAs` in the XML dataset format in-process, for real. PDF, RDLC, Word, and Excel layouts are not supported yet — and if your test tries to render one, it throws the out-of-scope error rather than silently skipping the rendering step. You'll know immediately that this is out of the runner's current scope, not that your report happens to work.

The DAP debugger and a `--coverage` flag are both still on the list, not shipped yet. Same rule applies: until they're built, anything that depends on them tells you so directly instead of pretending to work.

## The parser migration found a real bug

Separately, the table and property parser moved from a regex-based approach to using BC's own syntax tree. The old regex parser didn't crash on malformed input — it silently returned wrong values. A semicolon inside a string literal like `'Open; pending review'` would truncate the property at the wrong point, and nobody would notice unless a test happened to check that exact value.

The migration itself revealed that: after it was merged, a follow-up pass found the regex parser had been mishandling CalcFormula filter conditions across the Base App the entire time — **100 signed conditions, 1,215 `const()` conditions, and 285 `filter()` conditions** parsed wrong. Not a regression from the migration. A bug the migration finally made visible. It's fixed now, but I'd rather say that plainly than pretend the rewrite was clean from the start.

## A separate repo whose whole job is to be correct

[BusinessCentral.AL.Language.Tests](https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests) is a companion suite that defines exactly how AL language features behave, kept deliberately separate from the runner itself. It's grown to 355 AL files and 211 test codeunits over a small fixture library of tables, enums, an interface, pages, a report, a query, and XMLports. On 2026-07-31 it absorbed AL Runner's own extra behavioral tests, so the language spec and the runner's own coverage now live in one place instead of two.

The reason it's a separate repo, and not just a folder inside the runner: with v1, some of these tests turned out to be wrong. Not the runner — the tests. Nobody had ever confirmed a given test actually described how real BC behaves, so a test built on a wrong assumption could sit there passing against the runner indefinitely, proving nothing.

That's fixed now. The suite has its own CI pipeline that runs the entire test set against a real BC Cloud sandbox, on two BC versions, booted with [BC on Linux](/posts/bc-linux-boot-time-and-al-go-fast-lane/) so it doesn't need a Windows runner. Every test in this repo has to actually pass against real Business Central before anyone trusts it. Once a test is proven correct against the real service, it becomes the reference. There's even a dedicated issue template in the repo for the case where a test passes on real BC but fails on the runner — and it says plainly: the test is correct, go fix the runner. That ordering is the whole point. The runner gets held to a standard that's already been checked against reality, instead of a standard someone just assumed was right.

## The takeaway

v1 proved you could run AL without a service tier. It just proved it for a narrower slice of real-world code than I'd assumed — and the people actually trying to use it on their own extensions told me so directly. v2 exists because "it works for pure unit tests" wasn't a useful answer to "does this work for my extension," and the honest answer for most extensions was no, not without real dependency code behind it.

The second change matters just as much as the first, even though it's less visible in a changelog: a test tool is only trustworthy if it tells you when it can't do what you asked. v2 does. If it can't run something faithfully, it says so, loudly, and your test fails instead of lying to you.
