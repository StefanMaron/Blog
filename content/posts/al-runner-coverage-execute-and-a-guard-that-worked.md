---
title: "AL Runner v2.2 and v2.3: Coverage, Quick Scripts, and a Watch Mode You Can Trust"
description: "Since the v2 cutover: code coverage for your AL test runs, running a snippet of AL without writing a codeunit for it, a watch mode that no longer reports fake failures mid-save, and about 130 fixes to places where the runner's behavior didn't match real BC. Plus shoutouts to the two AL developers whose bug reports drove most of them."
date: 2026-08-20T07:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'AL Runner', 'Testing', 'Open Source']
---

I last wrote about [AL Runner](https://github.com/StefanMaron/BusinessCentral.AL.Runner) on August 10, the day the [v2 rewrite](/posts/al-runner-v2-emit-through-bc/) shipped — the tool that runs your AL unit and integration tests without spinning up a BC service tier. The [weekly recap four days later](/posts/weekly-recap-2026-08-14/) covered the first round of follow-up fixes. This post covers what happened after that, through v2.3.1 on August 19: two new capabilities, a watch mode you can actually trust during a busy editing session, and roughly 130 fixes to places where the runner used to disagree with real Business Central.

## You can now see what your tests actually cover

Run with `--coverage` and you get a real statement-coverage report for your test run — which lines of your AL code your tests actually executed, not an estimate. It uses the same mechanism BC's own compiler already tracks internally, so the numbers reflect real execution, not a guess based on which procedures got called.

If you've ever had a test suite that passes and "feels" thorough but you're not sure whether it's actually exercising your validation logic or just your happy path, this is the answer. Point `--coverage` at a codeunit and see, line by line, whether your `OnValidate` trigger's error branch ever actually ran.

## Run a line of AL without writing a test codeunit for it

Before this, if you wanted to check what a piece of AL code actually does — evaluate an expression, check how a function behaves, sanity-check a calculation — you had to write a full test codeunit, compile it, and run it through the test pipeline. There was no shortcut.

Now the runner's `execute` command accepts a bare snippet of AL directly: something like `Error('computed %1', 6 * 7);` runs immediately and tells you what happened, no codeunit wrapper required. If you paste in a full `codeunit` definition instead, it runs that verbatim. This closes a gap that's been open since the very first version of the tool — genuinely useful for quickly checking "what does this expression actually evaluate to" without the ceremony of a real test.

## Watch mode stopped lying to you mid-save

This is the fix I think matters most for anyone running `--watch` day to day. Previously, the runner would wait a fixed quarter-second after the *first* file change it noticed, then compile and test whatever was on disk at that moment. That's fine for a single save. It's not fine for a branch switch, a `git pull`, a rebase, or your formatter touching a dozen files — those all land as a burst of changes spread over a second or more, and the old fixed wait would fire in the middle of it. You'd get a compile and a test run against a tree that's half your old code and half your new code, and a test that's actually fine on both sides would fail for a reason that has nothing to do with your code.

The runner now waits until your files have genuinely stopped changing before it starts a cycle — however long that burst of saves actually takes, capped at 10 seconds so it can't hang forever. If you've ever seen `--watch` report a red test right after a branch switch that turned out to be a fluke on a second run, this is exactly that bug, and it's fixed.

Watch mode also got noticeably faster for the common case: editing the body of one object you're actively working on. Previously every save triggered a full rebuild of your entire app. Now, editing an existing object's content re-tests almost instantly instead of waiting for the whole app to recompile — in one measurement, about 18x faster on a 2,000-object app. Anything more unusual — a new file, a renamed object, a dependency change — still falls back to a full rebuild, so you never get a stale or wrong result, just no speedup for that particular save.

## About 130 fixes to how the runner behaves like real BC

Most of what shipped in this window is small, individually easy-to-miss fixes to places where the runner's behavior didn't match what real Business Central actually does. None of these are guesses about how BC "probably" works — every one is backed by a test in my [AL Language Tests](https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests) repository, which runs against an actual, running BC service tier. If the runner and real BC disagree, the sandbox result wins and the runner gets fixed to match it, not the other way around.

A sample of what that looked like in practice, all now fixed:

- **TestPage** field `Caption()` was returning the field name instead of the real caption; `Visible()` on a field ignored whether its enclosing `group()` was itself visible; `DrillDown()` never actually dispatched `OnDrillDown`; and `AutoSplitKey` numbered new subpage rows from a constant instead of the actual grid data.
- A **`TestField`** error raised from inside a Base App table trigger was, for a while, getting silently replaced by an unrelated page-resolution error — meaning your test would fail with a message that had nothing to do with what actually went wrong.
- **`Page.RunModal`**, both the static and instance forms, now correctly resolves the target page in cases that used to throw, including pages with an `Enum`-typed page variable.
- **Event subscribers** declared with `EventSubscriberInstance = Manual` are now honored correctly for both codeunit-level and table-level events — previously a manually-bound subscriber could fire unbound or never fire at all.
- **`Rename()`** now propagates correctly through `TableRelation`s that are conditional or `where()`-filtered, instead of only through the simple case.
- **`DeleteAll()`/`ModifyAll()`** now correctly open a write transaction even when zero records match — matching real BC's transaction behavior instead of silently skipping it.
- A report's **`GetFilter()`** now reads the filter your caller actually applied when called from inside `OnPreReport`, instead of reading empty.

None of these are dramatic on their own. Together, they're what closing the gap between "the runner runs your test" and "the runner behaves like the real product" actually looks like in practice.

## Two AL developers filed most of the bug reports behind this

**Flemming Bakkensen** filed 28 of the issues behind these fixes, and wrote 9 of the fixes himself. His reports cluster almost entirely around TestPage behavior and event dispatch — exactly the areas above. He also caught a real regression early: a fix that had shipped days earlier had quietly broken `TestField` error reporting from Base App table triggers, and he flagged it before it did more damage.

**Mikkel Mansa Vilhelmsen** (`vhn`) filed 14 issues, mostly around how `app.json` settings get respected — the runner was silently ignoring the `features` and `preprocessorSymbols` settings, which meant an app using `NoImplicitWith` could lose objects to false compile errors, and the wrong `#if` branch could compile in without any warning. He also filed the report that led to the watch-mode fix described above.

Both of them consistently filed reports with a precise, reproducible case attached rather than a vague "this doesn't work" — that's a meaningfully different kind of contribution than a one-line bug report, and it's a big part of why this window's fixes landed as quickly as they did. Thank you to both: [Flemming Bakkensen](https://github.com/FBakkensen) and [Mikkel Mansa Vilhelmsen](https://github.com/vhn).

## It also got faster to just start

Two separate rounds of work went into how long it takes the runner to spin up and run your tests, on top of the correctness fixes. Both were about overhead that had nothing to do with your actual AL code — internal startup costs the runner was paying on every single invocation. Fixing them cut a warm test run of a trivial fixture from about 23 seconds down to 5, and knocked roughly a quarter off the time every runner process takes just to get going, before your tests even start.

## Where things stand

As of v2.3.1: 815 out of 815 unit tests and 1,904 out of 1,904 language-behavior tests passing, across every supported BC version from 27.0 through 28.4. The companion [AL Language Tests](https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests) suite — the corpus that pins down exactly how real BC behaves, verified against a real BC sandbox — grew by five more confirmed test cases in this window, each one closing a gap the runner had to catch up to.
