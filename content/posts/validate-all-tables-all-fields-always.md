---
title: "Validate() – All Tables / All Fields / Always"
description: "Stefan Maroń and Christian Hovenbitzer argue at BC TechDays 2024 that Validate() should be the default in AL — not the exception — covering performance myths, chained validates, temp table pitfalls, and the cases where assignment is actually fine."
date: 2024-06-16T09:00:00+01:00
draft: false
tags: ['Videos', 'Business Central', 'AL', 'LinterCop', 'Performance', 'Testing']
---

At BC TechDays 2024 in Antwerp, Christian Hovenbitzer and I gave a session with a deliberately provocative title: *Validate() – all tables / all fields / always*. The room was packed, which tells you this is something people have strong opinions about.

You can [watch the full recording on YouTube](https://youtu.be/EucBX5IYt6k) if you want to follow along.

The short version of our argument: calling `Validate()` on a field should be your default. Skipping it should require a conscious, documented decision — not habit.

## What Validate() Actually Does

Before getting into the argument, it helps to be precise about what calling `Validate()` on a record field does.

It checks the table relation (if one exists and validation is not disabled), and it executes validate code in exactly five places — in this order:

[![Slide showing the execution order: EventSubscriber OnBeforeValidate, Table Extension OnBeforeValidate, Table OnValidate, Table Extension OnAfterValidate, EventSubscriber OnAfterValidate](/images/validate-all-tables-all-fields-always/01-definition-of-validate.jpg)](https://youtu.be/EucBX5IYt6k?t=216)

What it does *not* check: `DecimalPlaces`, `Min/MaxValue`, `CharAllowed`, and a few other properties. Those only fire for user interface validation — when a user types into a field on a page. From code, they're silently ignored.

> **📖 Docs:** The full `Record.Validate` method reference, including the optional `NewValue` parameter, is on [Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-validate-method).

## The Core Argument

Why should you always validate? Three reasons.

**You always want valid data.** That sounds obvious, but the interesting part is the second reason: you don't actually know what "valid" means for a given field at runtime. In C/AL days you merged every module manually into one database. You knew exactly what code was in there. In AL, any extension can attach `OnBeforeValidate` or `OnAfterValidate` to any field — including Microsoft pushing new base app updates without you noticing. The definition of valid for a given field can change at any point in time.

**Not calling validate potentially breaks other extensions.** If an AppSource app registers an event subscriber on a field's validate trigger to populate its own data, and your code just does `:= someValue` instead, their logic never runs. That's your bug, not theirs.

[![Slide: "You always want valid data / You don't know what the definition of valid is for a given field / Not calling validate potentially breaks extensions / Especially valid for AppSource Apps / Extension based development vs one large code base / AL (Events, extensions) vs C/AL"](/images/validate-all-tables-all-fields-always/02-why-always-validate.jpg)](https://youtu.be/EucBX5IYt6k?t=540)

Pages always call validate — fortunately. The question Christian raised that started this whole session: if pages never let you skip validation, why should developers writing AL code be allowed to?

## "But what if performance is bad?"

This was the most common objection we collected from the community. The slide I enjoyed showing here was this one:

[![AL code showing an event subscriber on OnBeforeCheckTotalInvoiceAmount in Sales-Post that sets IsHandled := true with the comment "For extra performance during posting. Also fixes some errors."](/images/validate-all-tables-all-fields-always/03-performance-bad-example.jpg)](https://youtu.be/EucBX5IYt6k?t=864)

Skipping checks to make things faster is not a performance optimization. It's a time bomb.

For actual numbers: Christian wrote six test functions — three variants each for a real `Sales Line` quantity validate and an empty validate on a custom table.

[![AL Test Tool showing benchmark results: ValidateSalesLineQty=17ms, ValidateQty1=30ms, ValidateQty1000=73ms, ValidateQty100000=7 seconds, EmptyValidateQty1=7ms, EmptyValidateQty1000=4ms, EmptyValidateQty100000=47ms](/images/validate-all-tables-all-fields-always/04-performance-benchmark-results.jpg)](https://youtu.be/EucBX5IYt6k?t=1080)

An empty validate on a field with no code: 7 milliseconds for a single call. Even 1000 of them come in at 4ms. For a real validate with actual business logic (the Sales Line quantity validation is not trivial), you're at 30ms per call — and if you genuinely need 100,000 of those, that's a bulk scenario where you should rethink the architecture, not skip the triggers.

If the validate code is genuinely slow, that's a bug. Report it. Don't bury it with an assignment.

## Chained (or Nested) Validates

The concern here is: if validating field A triggers a validate on field B which triggers field A again — you have a loop.

The answer is that if the code was designed that way, there's probably a reason. And if the order matters, the table should expose a helper function. This is the pattern we showed:

[![VS Code showing NestedValidate.table.al with UnitPrice.OnValidate calling Validate(UnitPriceIncludingVat) and Validate(LineAmount), and a procedure UpdateAmounts(NewAmount, NewDiscount) that validates them in the correct order](/images/validate-all-tables-all-fields-always/05-nested-validate-helper-function.jpg)](https://youtu.be/EucBX5IYt6k?t=1296)

If you have fields like `UnitPrice`, `UnitPriceIncludingVat`, `LineAmount`, and `Discount` where only two actually need to be called externally, put a function on the table that takes those two values and validates them in the right order. Your callers don't need to know the internal dependency graph.

For the circular case — classic example: `StartDate` and `EndDate` validating each other — a clean pattern is to assign both fields first, then call `Validate()` on them without a new value. The validate triggers still fire and check the table relation, but since the assignment already happened, there's no loop.

[![VS Code showing StartEndingDate.table.al with a SetStartEndDate procedure that assigns StartDate and EndDate first, then calls Validate(StartDate) and Validate(EndDate) without new values](/images/validate-all-tables-all-fields-always/06-circular-validate-start-end-date.jpg)](https://youtu.be/EucBX5IYt6k?t=2160)

One caveat: if the validate code checks `xRec` to detect whether the value actually changed, this pattern won't work — the validate won't see a change because the assignment happened before the trigger fired. Write validate code that doesn't depend on that where possible.

## Temporary Tables

We split this into two cases.

**Dedicated temporary tables** (table type `Temporary`) — validate normally. The code on that table knows it's running in a temporary scope, and it was designed for it. No special handling needed.

**Hijacked temporary tables** — a regular table used as a temporary record variable (classic example: `Sales Line` used as a temp buffer). This is where it gets dangerous, and Christian had a demo to illustrate why.

[![VS Code showing TemporaryDimensionsTable.al with a comment "Bad example" and code calling DimensionManagement.ValidateShortcutDimValues, which creates new Dimension Set Entries in the real database even when operating on a temp table](/images/validate-all-tables-all-fields-always/07-temp-table-bad-example.jpg)](https://youtu.be/EucBX5IYt6k?t=2700)

The problem: when you call `DimensionManagement.ValidateShortcutDimValues` (a base app codeunit), that function creates a new Dimension Set Entry in the database if one doesn't exist yet. It doesn't know it's being called from a temporary scope. So you end up with real database records created as a side effect of working with a temp table — and that's one of the gentler examples. Imagine what happens with something that writes sales documents.

Our recommendation: avoid hijacking regular tables as temp tables in the first place. Create a dedicated temporary table for your scenario. If you genuinely can't avoid it, decide on a case-by-case basis whether to call validate, and check that the validate code handles `IsTemporary()` correctly.

## Exceptions — When to Use Assignment Instead

There are legitimate cases to skip `Validate()`:

[![Slide: "Exceptions – When to rather use assignment: Test Code / Highjacked temporary tables / If validate code is buggy (Until bug is resolved)"](/images/validate-all-tables-all-fields-always/09-exceptions.jpg)](https://youtu.be/EucBX5IYt6k?t=3672)

**Test code** is the clearest one. In tests you want to control exactly which fields have which values to create a reproducible setup. Validating during test data preparation introduces unpredictability — third-party extensions might subscribe to the trigger and modify your test data under you. If you want to test validation code, call validate in the `[When]` step. If you're just building the `[Given]`, assign.

**Data migration tables** (tables that exist only to hold data during a migration before being destroyed) — technically fine to skip validate. They have no code, won't get extended, and won't be touched again after the migration.

**Buggy validate code** — if there's a confirmed bug that makes the trigger unsafe to call, you can skip it with an assignment as a temporary workaround. Document it with a `// TODO` comment, report it, and remove the workaround when the fix ships.

## TransferFields, ModifyAll, DataTransfer

These three all have the same characteristic: they don't execute validate triggers.

[![Slide: "Transferfields/ModifyAll/Datatransfer – No Validates get executed" with detailed notes on each: TransferFields mostly for posted tables, ModifyAll is a less-code version that still skips validation, DataTransfer only usable in upgrade code](/images/validate-all-tables-all-fields-always/10-transferfields-modifyall-datatransfer.jpg)](https://youtu.be/EucBX5IYt6k?t=4212)

`TransferFields` is mostly used for posting — copying from a document to a posted document. The argument "posted tables don't have validate code" is less true every day; extensions do add it. It also doesn't protect you against field ID mismatches.

`ModifyAll` skips all validate triggers. The workaround if `OnModify` code exists is just to loop and validate manually. Stefan mentioned wanting a third parameter on `ModifyAll` that would run validation triggers when code is present — that idea was out there as a feature request but hadn't landed at the time of the session.

`DataTransfer` doesn't call any triggers by design, and is only available in upgrade codeunits — so it's at least limited in scope.

## The Don'ts Slide

The full summary of what not to put in a validate trigger:

[![Conclusion "Don'ts" slide listing: Database operations (IMD) to move to OnModify, temp tables, testability issues, unwanted write transactions, forced validation order, calling other people's databases (web services), invocation of any UI, Record.ChangeCompany, Rec.Modify/Insert/FindFirst/FindSet/Find, CurrFieldNo/xRec](/images/validate-all-tables-all-fields-always/08-conclusion-donts.jpg)](https://youtu.be/EucBX5IYt6k?t=3348)

The `Record.ChangeCompany` one in there is half a joke, but only half. The `CurrFieldNo` and `xRec` points are serious — both work fine when called from a page (as they were designed for), but behave unexpectedly when called from code, and both are hard to test correctly.

## LinterCop Rule

During Q&A, someone asked if I'm planning to add a LinterCop rule for this. The answer at the time was: yes, the idea is there. It would probably be an opt-in (disabled by default) rule that warns on `:=` assignments to fields when validate should be called. I hadn't worked out the pragma/suppression story for the exceptions yet.

## Start Refactoring

If you have a codebase full of `:=` assignments you want to convert, the [AL Code Actions extension by David Feldhoff](https://marketplace.visualstudio.com/items?itemName=davidfeldhoff.al-codeactions) can refactor them in bulk. Select the assignments, run the code action, done.

> **📖 Docs:** LinterCop, the community linter for AL, is on [GitHub](https://github.com/StefanMaron/BusinessCentral.LinterCop). A future rule for enforcing `Validate()` calls is something I've been thinking about — feel free to open an issue or vote for it there.

The deeper point is the mindset shift: validate is the default. Assignment is the exception that needs a reason.

---

*This post was drafted by Claude Code from the session recording and slides from BC TechDays 2024. The [full recording is on YouTube](https://youtu.be/EucBX5IYt6k) if you want to watch the demos and Q&A. (I did read and check the output before posting, obviously 😄)*
