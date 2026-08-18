---
title: "I Can Turn Off My Code. I Can't Turn Off Yours."
description: "Setting RunTrigger to false on Insert, Modify, or DeleteAll doesn't just skip your own logic — it skips everyone else's subscribed to that table too. That's why running every trigger has to be the default, and why the real fix for the performance cost isn't a developer's judgment call at all: it's the platform checking, per execution, whether there's any code to run in the first place."
date: 2026-08-18T09:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'Performance', 'Code Quality']
---

When a developer sets `RunTrigger` to `false` on `Insert`, `Modify`, or `DeleteAll`, they're not just skipping their own logic. They're turning off every subscriber on that table — base app code, every third-party extension currently installed, anything a future extension update adds. My own logic, I get to decide about. Logic that isn't mine, I don't, and I have no way to find out what I'd be turning off before I do it.

That's why running every trigger has to be my default, always, and skipping one has to be the rare exception — made deliberately, for a specific and documented reason, never just "it would be faster."

I made this argument two years ago at BC TechDays about `Validate()`, together with Christian Hovenbitzer. Since then I've spent two years arguing it with people who disagree, including technical people at Microsoft. Last night's work gave me a case with real numbers attached, which is what got me writing about it again.

## Last night, briefly

I was profiling a slow customer import — a routine that reads a source file and builds general journal lines from it, line by line, over 14,000 lines in the test run. It called `Modify()` three separate times per line as different fields got filled in, and each call reran the base app's entire `OnModify` chain for the whole record. Consolidating those three calls into one measured 20% faster, and it changed nothing about which triggers ran — every subscriber still saw the same "inserted, then modified once" shape it expects.

I also built a version with no `Modify()` call at all, which measured 32% faster. I didn't ship it. It would have silently turned off `OnModify` for a third-party app I'd noticed subscribed to that chain — code I can't inspect and can't test against locally. Twelve extra percentage points wasn't a good enough reason to make that decision on someone else's behalf.

## Why people push back — and they have a point

The pushback I hear most, from people who know the platform better than I do, is about bulk operations specifically: large inserts, `ModifyAll`, `DeleteAll`. SQL Server and the service tier in front of it are built to send writes in bulk — one round trip for a thousand rows instead of a thousand round trips. A trigger firing per row forces row-by-row execution and throws that batching away. `DeleteAll` without triggers deletes everything in one bulk operation; force it to run triggers and you get the same result, but one row at a time, which is the entire performance reason to reach for `DeleteAll` in the first place, gone. That's a real cost, not an imagined one.

## The trade-off isn't real — the platform just hasn't closed it

Here's the actual point. This looks like a trade-off between correctness and performance only because of how the decision is currently wired: as a boolean, set once, at the call site, at the moment the code is written. But whether a trigger needs to run isn't a question that can be answered at that moment. It's a question about one specific execution, on one specific table, in one specific company, at runtime — is there code registered on that trigger right now, or isn't there?

If there isn't, skipping it costs literally nothing, because nothing was going to happen anyway. If there is, skipping it means someone else's logic silently doesn't run — which is precisely the decision I don't think is mine to make. Either way, the platform can answer that question correctly, every single time, because it's the only party that actually knows what's currently registered on a table. A developer guessing at compile time never can.

## What I think should change

I don't think this should be a decision developers keep making, one call site at a time, forever. We've established why we can't make it well — we don't know what's registered, and we can't. So it shouldn't be ours to make. This is a platform capability, and building it is Microsoft's to do, not something every AL developer should have to work around project by project.

Concretely, and this is the piece that actually matters most: keep `RunTrigger` exactly where it is today, on `Insert`, `Modify`, `ModifyAll`, `DeleteAll`. The ability to explicitly forbid a trigger from running, for a documented reason, should stay available — that part of this isn't broken. What should change is what setting it to `true` actually means. Today, asking for triggers to run forces row-by-row execution unconditionally, whether or not anything is actually registered to run. It should instead mean "run the trigger if there is one" — and when the runtime checks and finds nothing registered for that operation on that table, it falls back to the same bulk SQL Server operation it would have used with `RunTrigger` set to `false`. My `true` stops being an instruction that forces the expensive path, and becomes a request the platform is free to satisfy however it actually needs to. That's the core capability, and everything else in this post depends on it existing — it isn't specific to `ModifyAll`, it applies everywhere a `RunTrigger`-style flag exists.

There's a second, separate problem, and it's specific to `ModifyAll`: today it can't ask for `Validate()` to run at all, only `OnModify`. `Validate()` isn't most of the business logic — it's part of it, same as `OnModify` is — but it's the part I have no way to ask `ModifyAll` to run, under any circumstance. That means if I care about the other developers and extension owners whose code might be subscribed to that field's validate trigger, I can't reach for `ModifyAll` at all, regardless of whether dynamic execution exists. The only way to run `Validate()` today is a manual loop, one record at a time, which throws away the entire reason to use `ModifyAll` in the first place.

That gap isn't a precondition for dynamic trigger execution — it's a separate fix, on top of it. But it's the logical next step once dynamic execution exists everywhere else: give `ModifyAll` an option to run `Validate()`, add the same runtime fallback to it, and it stops being unusable for the cases where correctness actually matters. Nothing registered, and it still gets the full SQL Server bulk operation. Something registered, and it runs correctly instead of not running at all.

## What other systems do about this

BC isn't the only place this tension shows up. Most systems that layer procedural business logic on top of bulk writes hit it, and the answers vary.

Most ORMs solve it the same way BC does today: not at all, they just make the bypass explicit. Rails' `update_all` and `delete_all` skip every model callback and validation, by design, and the documentation says so directly. Django's `QuerySet.update()` skips the model's `save()` method and its signals the same way. Hibernate's bulk HQL `UPDATE`/`DELETE` statements bypass the persistence context and any `@PreUpdate`/`@PostUpdate` lifecycle callbacks. None of them check whether a callback is actually registered before deciding to skip it — the developer chooses the bulk path and accepts that callbacks won't run.

That comparison only goes so far, though. Rails, Django, and Hibernate are general-purpose — their authors have no idea what any given app built on them actually needs, so leaving the bypass decision to that app's developer is a reasonable default. BC isn't in that position. It's one specific, known application: accounting software, where a skipped trigger can mean a posting, a tax calculation, or a ledger entry that silently never got checked. The technical tension — bulk writes versus per-row logic — is the same everywhere. The conclusion isn't. A permissive default that's defensible in a framework that could be running anything is a weaker choice in software that's always running the same thing, and that thing can't tolerate wrong data.

The more interesting answer is sitting one layer down, in SQL Server itself. A native SQL Server trigger doesn't fire once per row — it fires once per statement, and gets handed the `inserted` and `deleted` pseudo-tables containing the entire affected set at once. Update ten thousand rows in one `UPDATE` statement, and a trigger on that table runs a single time, operating on all ten thousand rows as a set. Oracle and PostgreSQL make this an explicit choice: `FOR EACH STATEMENT` triggers fire once per statement over the whole set, `FOR EACH ROW` triggers fire once per row when the logic genuinely needs per-row context. The database underneath BC already knows how to do this. AL's `OnModify`/`OnValidate` model doesn't use that pattern at all — it's built as procedural code against one `Record` variable, invoked once per record, which is exactly why it can't cheaply batch.

Salesforce took a different route with Apex triggers: instead of giving developers a bypass switch, the platform simply never hands a trigger one record at a time. `Trigger.new` is always a list, batched up to 200 records per invocation, and writing a trigger that assumes a single record is considered a bug in Salesforce's own developer documentation, not an edge case. A bulk load of 50,000 records still only invokes the trigger handler a few hundred times, not 50,000 — because the unit of execution was never "one row" to begin with.

None of these is a drop-in fix for BC, and none of them is exactly the runtime check I described above either. But they all point at the same underlying move: the fix isn't a bypass switch for the developer to flip. It's changing what "running the trigger" costs, either by making the trigger's unit of work a set instead of a row, or by moving the check for whether there's anything to run into the platform instead of the call site.

## The default, and the exception

Running every trigger stays my default because I can never verify, on my own, what turning one off would silently break for someone else. When I do skip one, it's for a specific, documented reason — a known bug in the trigger, a genuinely temporary table, something I can name — never "it's faster this way." What I described above is what would make that default nearly free, most of the time, without asking a developer to make the call at all.

---

*This post is drawn from a real performance trade-off in client work from last night, generalized here — no client name, product name, or specific business logic. I reviewed and edited it before posting.*
