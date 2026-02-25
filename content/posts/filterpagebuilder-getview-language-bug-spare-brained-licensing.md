---
title: "FilterPageBuilder.GetView, Language Bugs, and Adding Spare Brained Licensing"
date: 2024-05-26T09:00:00+01:00
draft: false
tags: ['Videos', 'Business Central', 'AL', 'AL-Go']
---

Two things on the agenda for this stream: fixing a subtle language-related bug in how I use `FilterPageBuilder.GetView`, and starting to integrate [Spare Brained Licensing](https://github.com/SpareBrainedIdeas/Spare-Brained-Licensing) into my Automatic Write-Offs app. The [full stream is on YouTube](https://www.youtube.com/watch?v=DQ5EMzLi1c8) if you want the unfiltered version.

## The GetView Language Bug

Someone pointed out in a comment on a previous video that the filter views I store in the database can break if a user switches language. I hadn't noticed it myself, but once I started digging it was obvious.

The `FilterPageBuilder.GetView` method has an optional second parameter called `UseNames`. Its default value is `true`, which means the returned filter string contains **field captions** rather than field numbers. That's fine for display, but the moment you persist that string — into a setup table, a database record, anywhere — and then a user opens it with a different language installed, the filter no longer applies correctly. The caption-based filter string is language-specific, and BC can't resolve it when captions differ.

[![GetView with UseNames parameter tooltip visible in VS Code](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/01-getview-usenames-tooltip.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=67s)

On stream I verified this by installing the German language pack and switching my test environment to German. With `UseNames = true` (the default), the saved filter simply disappeared — BC couldn't load it. With `UseNames = false` the filter string uses field numbers (`VERSION(1) SORTING(Field1) WHERE(Field1=1(10000))` and similar), which are language-neutral and load fine in every language.

[![Filter string using field IDs instead of captions on the Automatic Write-Off Setup page](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/03-filter-string-field-ids.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=871s)

The fix is a one-liner in every place you call `GetView` on a `FilterPageBuilder`:

```al
TargetFilter := CopyStr(CustomerFilter.GetView(Customer.TableCaption, false), 1, MaxStrLen(TargetFilter));
```

> **📖 Docs:** [`FilterPageBuilder.GetView(Text [, Boolean])`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/filterpagebuilder/filterpagebuilder-getview-method) — if `UseNames` is `true` (the default), the returned string contains field captions. Set it to `false` to get field numbers instead, which is what you want whenever you store a filter string.

[![VS Code diff view showing GetView called with false to use field IDs](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/02-getview-false-fix.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=938s)

In my extension there were only two call sites. In a larger codebase you'd want to search for every `GetView` on a `FilterPageBuilder` and check each one. Toward the end of the stream I mentioned this could be a good LinterCop rule — a diagnostic that warns whenever `GetView` is called without explicitly setting `UseNames` to `false`. Something to look at in a future stream.

## Integrating Spare Brained Licensing

The Automatic Write-Offs app is heading to AppSource as a paid extension, so it needs licensing enforcement. I've used [Spare Brained Licensing](https://github.com/SpareBrainedIdeas/Spare-Brained-Licensing) by Jeremy Vyska before and it's the right tool for this. It's open source, free, available on AppSource, and supports both Gumroad and Lemon Squeezy out of the box — those platforms handle all the VAT, payment processing, and affiliate logic, so you just receive money.

[![Spare Brained Licensing README on GitHub showing the License Key Framework description](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/04-spare-brained-licensing-readme.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=1072s)

Jeremy recently merged the separate PTE and AppSource versions of the library into a single build, which makes things simpler. Since Microsoft opened the AppSource object ID range for development with the CRONUS license, there's no longer a reason to maintain two numbering schemes.

The first step was cloning the Spare-Brained-Licensing repo, fixing a backslash/forward slash issue in the VS Code settings (Jeremy uses backslashes — forward slashes work everywhere, including Windows), publishing the extension to my BC container, and then adding a dependency in my Automatic Write-Offs `app.json`.

Next came writing the install codeunit logic. In `HandleFreshInstall` I call `ExtensionsRegistration.RegisterExtension` with the app info, product code, support URL, billing email, grace period days, minimum licensing version, and the license platform enum set to `LemonSqueezy`:

```al
ExtensionsRegistration.RegisterExtension(
    AppInfo,
    'test',
    'someUrl.com',
    'someUrl.com',
    'billing@email.com',
    '',
    14,
    14,
    Version.Create(1, 0, 0, 0),
    Enum::"SPBLIC License Platform"::LemonSqueezy,
    true
);
```

[![InstallWriteOff.Codeunit.al showing AddTestProduct with LemonSqueezy enum and grace period parameters](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/05-licensing-install-lemon-squeezy.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=2144s)

The actual product code and API keys will be filled in off-stream once I've wired up the Lemon Squeezy side. The structure is in place.

## Gating the Generate Action

With registration done, I also need to prevent the app from working without a valid license. I created a small `CheckActive` codeunit wrapper that calls `CheckBasic(AppInfo.Id, true)` — the `true` flag means BC will surface an error to the user if the license is inactive rather than silently returning false.

I call this at the top of the `Generate` action trigger on the Write-Off Documents page, and also at the top of each `WriteOff` implementation codeunit:

```al
trigger OnAction()
var
    CheckActive: Codeunit "SPBLIC Check Active";
    AppInfo: ModuleInfo;
    WriteOff: Interface WriteOffWOABG;
begin
    NavApp.GetCurrentModuleInfo(AppInfo);
    CheckActive.CheckBasic(AppInfo.Id, true);

    WriteOff := WriteOffType;
    WriteOff.WriteOff(WriteOffType, TargetFilter, WriteOffLimit, CutOffDate);
    WriteOff.InvokeTargetPage();
    CurrPage.Close();
end;
```

[![WriteOffDocuments.Page.al showing the Generate action with CheckActive.CheckBasic call](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/06-generate-action-license-check.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=2211s)

## A Bug I Found in the Library

While testing I tried forcing the grace period to zero days to verify the license check actually blocks the app. It didn't block it — the app was still usable on the day of install even with `daysAllowedBeforeActivation = 0`. Looking at the `RegisterExtension` source in the library, the grace end date is calculated as:

```al
if GraceDays > 0 then
    GraceEndDate := CalcDate(StrSubstNo(PlusDaysTok, daysAllowedBeforeActivationProd), Today)
else
    GraceEndDate := Today;
```

When `GraceDays = 0`, `GraceEndDate` gets set to today, which means the app is still licensed today. If you want zero grace — no trial at all — you'd expect `GraceEndDate` to be yesterday (or at least a date before today). I filed an issue against the Spare-Brained-Licensing repo for this. It might be intentional behaviour, but it surprised me.

[![GitHub issue being filed: GraceEndDate should not be today if daysAllowedBeforeActivation is zero](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/09-github-issue-grace-end-date.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=3082s)

## AL-Go Dependency Wiring

The final piece is telling AL-Go to pull the Spare-Brained-Licensing app automatically during CI builds. That goes in the `appDependencyProbingPaths` setting in `AL-Go-Settings.json`:

```json
"appDependencyProbingPaths": [
  {
    "repo": "https://github.com/SpareBrainedIdeas/Spare-Brained-Licensing",
    "version": "latest",
    "release_status": "release",
    "projects": "*"
  }
]
```

> **📖 Docs:** [AL-Go — Introducing a dependency to an app on GitHub](https://github.com/microsoft/AL-Go/blob/main/Scenarios/AppDependencies.md) — `release_status` accepts `release`, `prerelease`, or `draft`. AL-Go can only pick up artifacts from AL-Go-built releases; a manually created GitHub release won't work here.

[![AL-Go AppDependencies documentation showing appDependencyProbingPaths structure](/images/filterpagebuilder-getview-language-bug-spare-brained-licensing/07-alg-app-dependency-probing-paths.jpg)](https://youtube.com/watch?v=DQ5EMzLi1c8&t=2814s)

The catch: for this to actually work in the pipeline, the Spare-Brained-Licensing repo needs a release that was created by AL-Go itself, not a manual one. I need to ask Jeremy to create one. Until then the local dev setup works fine, but the CI build won't be able to resolve the dependency automatically.

---

*This post was drafted by Claude Code from the stream transcript and video frames. The [full stream is on YouTube](https://www.youtube.com/watch?v=DQ5EMzLi1c8) if you want the unfiltered version. (I did read and check the output before posting, obviously 😄)*
