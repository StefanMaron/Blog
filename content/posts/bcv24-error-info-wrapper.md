---
title: "BCv24 Error Info Wrapper - Backporting the Fluent ErrorInfo API"
description: "How to backport a fluent AL ErrorInfo wrapper to Business Central v24 by working around the missing 'this' keyword with a global variable and internal"
date: 2024-07-10T09:00:00+01:00
draft: false
tags: ['Videos', 'Business Central', 'AL', 'Error Handling']
---

On a recent stream I built a fluent wrapper around the `ErrorInfo` data type that lets you chain calls like `ErrorInfoWrapper.Title('...').Message('...').AddAction(...)`. The original implementation used the `this` keyword, which is only available from AL runtime 14.0 (Business Central v25) onwards. Someone in the chat — I think it was Natalie — pointed out that it would only work on v25+. I was pretty sure we could make it work on v24 too, so that's what this stream was about.

Watch the full stream here: [BCv24 Error Info Wrapper on YouTube](https://www.youtube.com/watch?v=yuooURDJBGg)

## The starting point

The wrapper is split into two codeunits: `ErrorInfoWrapper` (the public API) and `ErrorInfoWrapperImpl` (the internal implementation). Each public method sets a property on the `ErrorInfo` object and then returns the codeunit itself, so calls can be chained. In the v25 version, `exit(this)` makes that trivial — you just return the current instance.

[![Starting state with this-keyword errors](/images/bcv24-error-info-wrapper/01-v24-starting-state-errors.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=0s)

The moment I set `runtime` to `13.0` in `app.json` and downloaded v24 symbols, the compiler lit up. Two problems immediately:

1. `this` is not available before runtime 14.0.
2. `CustomErrorInfo` (the internal `ErrorInfo` variable) is inaccessible from within a procedure that is operating on a different instance of the codeunit.

[![app.json with runtime 13.0 targeting BC 24.0](/images/bcv24-error-info-wrapper/02-appjson-runtime-13.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=176s)

> **📖 Docs:** The `ErrorInfo` data type has been available since runtime 3.0. The fluent chaining pattern relies on returning a codeunit instance from each method — which in turn requires the `this` keyword, introduced in runtime 14.0. See [ErrorInfo data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/errorinfo/errorinfo-data-type).

## Why `this` matters for chaining

The public `ErrorInfoWrapper` codeunit holds a variable `this: Codeunit ErrorInfoWrapper` at the top. Each method sets a property on the internal `CustomErrorInfo: ErrorInfo` variable and then does `exit(this)`. That way the caller gets back the same instance and can keep chaining.

Without `this` in v24, `exit(this)` is a syntax error. And even if you replaced it with your own global variable trick, you run into the protection level problem: a procedure inside `ErrorInfoWrapperImpl` cannot directly assign to `CustomErrorInfo` declared on a different codeunit instance.

[![Compiler errors after switching to runtime 13](/images/bcv24-error-info-wrapper/04-compiler-errors-this-keyword.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=284s)

## The workaround

The fix has two parts.

**Part 1 — keep a parallel global variable.** Because we can't use `this`, we need a top-level variable that holds the codeunit instance we want to return. That's `this: Codeunit ErrorInfoWrapper` declared as a global variable at the top of `ErrorInfoWrapper`. Each method sets its property, then does `exit(this)` where `this` is now just an ordinary variable name (not a keyword). The compiler is happy.

**Part 2 — route mutations through an internal setter.** Because direct access to `CustomErrorInfo` from a method running on a different instance is blocked (protection level), I added a single internal procedure:

```al
internal procedure SetCustomErrorInfo(ErrorInfoParam: ErrorInfo)
begin
    CustomErrorInfo := ErrorInfoParam;
end;
```

Every setter method now follows the same two-line pattern:

```al
procedure Title(TitleParam: Text): Codeunit ErrorInfoWrapper
begin
    CustomErrorInfo.Title := TitleParam;
    this.SetCustomErrorInfo := CustomErrorInfo;
    exit(this);
end;
```

First update the local copy, then push it into the global variable via the setter. It's redundant — effectively two instances of the same codeunit kept in sync at all times — but it compiles, and it works.

[![SetCustomErrorInfo internal procedure being introduced](/images/bcv24-error-info-wrapper/05-set-custom-error-info-workaround.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=374s)

I used an AL quirk to make the search-and-replace easier: if a procedure has exactly one parameter, you can assign to it using the `:=` syntax. So `this.SetCustomErrorInfo := CustomErrorInfo` is valid and passes `CustomErrorInfo` as the argument. That's a leftover from the old C/AL days, and it came in handy here.

## The result

After working through all the procedures — `Title`, `Message`, `DetailedMessage`, `AddCustomDimension`, `ControlName`, `DataClassification`, `AddNavigationAction`, `AddAction`, `Collectible`, `ErrorType`, `Verbosity`, and `GetErrorInfo` — the code compiled clean and published to the v24 container.

[![Complete v24 implementation — GetErrorInfo returns CustomErrorInfo](/images/bcv24-error-info-wrapper/06-complete-v24-implementation.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=726s)

The test codeunit fires the wrapper on `OnOpenPage`, and the error dialog shows up exactly as expected:

[![Error dialog showing "This is the error wrapper with v24 implementation"](/images/bcv24-error-info-wrapper/07-error-dialog-working-v24.jpg)](https://youtube.com/watch?v=yuooURDJBGg&t=858s)

## A documentation fix on the main branch

While I was at it, someone had posted on Twitter that `Collectible` set to `true` via `ErrorInfo.Create()` doesn't actually behave as documented. I went back to the main branch and removed the claim from the XML docs. Either Microsoft fixes the behaviour so it matches the docs, or fixes the docs — but it shouldn't say it works if it doesn't.

## Is the overhead worth it?

Honestly, no — not for production code you're going to maintain long-term. Every setter touches the `ErrorInfo` struct twice, and you're running two instances of the same codeunit in lockstep. It's technical debt.

But if you need the fluent API right now and can't wait for v25, or if your customers are on v24 and you want to ship the wrapper as a dependency, it works. The code is on GitHub on the `v24Implementation` branch:

[github.com/StefanMaron/ErrorInfoWrapper](https://github.com/StefanMaron/ErrorInfoWrapper/tree/v24Implementation)

I'll put in a PR to the BCApps repo for the proper v25 version once I have sign-off to do so.

> **💡 Added context:** The `this` keyword in AL is the idiomatic way to implement fluent builder patterns on codeunits. It returns the current codeunit instance, avoiding the need to keep a separate reference variable. It was added in runtime 14.0, which shipped with Business Central 2024 release wave 2 (v25). Runtime 13.0 targets v24 — hence the workaround needed here.

---

*This post was drafted by Claude Code from the stream transcript and video frames. The [full stream is on YouTube](https://www.youtube.com/watch?v=yuooURDJBGg) if you want the unfiltered version. (I did read and check the output before posting, obviously 😄)*
