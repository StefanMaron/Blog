---
title: "How to Set Up a New Business Central Development Project – The 100% Correct Way"
date: 2025-06-05T07:32:18+02:00
draft: false
---

# How to Set Up a New Development Project/App — The 100% Correct Way

The foundation of any good Business Central app is the way it's set up. That might sound obvious, but it's also one of the most overlooked steps in AL development.

Too often, projects start with a quick `AL: Go!` command and get to writing objects immediately — skipping over critical setup tasks that ensure long-term maintainability, CI/CD readiness, testability, and AppSource compatibility. Even if you do not plan to go to AppSource, many of the requirements make a lot of sense even for a PTE.

This post is about doing it right from the start. No shortcuts. No assumptions. Just the correct, supportable, scalable way to start a new Business Central app — whether you're building a PTE, an ISV solution, or a shared internal library.

> ⚠️ This isn't a tutorial for beginners. This guide assumes you're already comfortable with AL development and want to improve the quality and discipline of your project setup.

Let's walk through the essential steps that form the base of every properly structured project.

## 2. Project Creation

The first mistake many developers make is starting with the default `AL: Go!` setup in Visual Studio Code. While it gets you running quickly, it leaves you with a very basic project structure which requires many tweaks and manual steps. 

Instead, start from a **template**. This can be your own template you maintain. AFAIK Cosmo Alpaca provides ready to use templates. I personally use AL-Go for GitHub so that's what I will describe here.

If you're using **AL-Go for GitHub**, Microsoft provides excellent templates you can use as a baseline. These templates include structured folder layouts, pipeline configuration, and GitHub workflows that support build, test, sign, and publish automation. Starting here ensures you're already aligned with modern AL development practices.

If you're not using AL-Go (yet), it's still worth maintaining your own template repo — something that includes:

* A basic compiling shell (no demo objects)
* Linter configuration
* Pre-configured `.vscode/settings.json`
* Common folder layout conventions
* A test app project

After creating the project from a template:

* **Remove all demo objects** like the "HelloWorld" page/codeunit.
* Make sure the project compiles cleanly in its base state.
* Download symbols immediately so you can start working with real object references.

Taking the time to start clean and structured will save you far more effort down the road — especially when working in teams, setting up CI/CD, or preparing for AppSource submission.

## 3. `app.json` Configuration

The `app.json` file is the heart of your AL project metadata. It deserves more attention than just plugging in a name and version. Doing this correctly avoids validation issues, deployment errors, and pipeline failures — and sets the tone for a professional app.

Here are the essential elements to configure correctly:

### `idRange`

Make sure to use the correct Id range for your app. If you develop for AppSource your company should have requested some id ranges. Remember: You can use a subset of the assigned ranges for your apps. And dont make the range too big, you can always assign additional ranges later if you run out of Ids.

For PTEs don't start at `50000`. The in client designer will create objects starting at `50000` which would fail if there are already custom objects using those ids.

### `name`

Choose a good extension name that actually describes what the app is doing.

### `publisher`

If you are a registered publisher for AppSource, always use the Company name that you have registered. Otherwise, choose the publisher name you are going to go with once, and stick with it. That makes it easier to identify and filter the installed extensions if you are going to publish multiple extensions.

### `version`

I see many extensions aligning the version with the Major.Minor of the Business Central the app was created against. I did the same thing when we started with Extensions and AL Development.
However, I do not do that anymore and I would not recommend it anymore.

The reason is, that you probably wont need to update the Extension itself as frequent as the Business Central is updated. In end your version will either be off or you will need to release new version just to change the Extension version. You might want to have your Extension compatible with multiple versions, in which case this approach also wont work.

Just start with `1.0.0.0` or even `0.1.0.0` to indicate a pre-release state.

### `description`

This is **mandatory** for AppSource apps, but useful even in PTEs. It helps others (and future-you) understand what the app is about at a glance.

### `application`

The `application` setting bundles the dependency to the Base app, the Business Foundation app and the system app. This should be the lowest version you want to support.

### `platform`

This can be left at `1.0.0.0` as the server version will always align with the `application` version.
The only exception would be if you do not need a dependency to `application` at all. Then I would set the `platform` version instead.

### `runtime`

Always specify these explicitly. Omitting `runtime` in particular can cause failures in CI pipelines or result in unpredictable compiler behavior.

### `dependencies` and `features`

Only include what's strictly needed. Avoid including preview or unnecessary features unless you have a solid reason.


## 4. Object Naming Conventions

Consistent and compliant object naming is essential — not just for readability, upgrade safety, and team collaboration. This is maybe one of the most controversy parts of AL development, and yet I think its pretty straight forward.

### Use Suffixes, Not Prefixes

Microsoft requires a **3-character affix** for all AppSource apps. These are registered and unique per publisher. This affix should be used as a **suffix**, not a prefix. That way it is way easier to find objects and fields based on the name.

### Add a 2-Character Project Code

To distinguish between projects (especially within a single publisher), add a 1/2-character internal project code before the affix. For example, if your affix is `PTE`, your suffix might be `SZPTE`.

- If the publisher has a registered affix, always use it.
- If not (yet), use `PTE` as the general fallback.

### Naming Principles

In Business Central, all Objects names are limited to 30 Characters. Instead of using the NAV naming convention with spaces `Posted Sales Invoice Header` I recommend to use **PascalCase** `PostedSalesInvoiceHeader`. This also removes the need of double quotes around identifiers.

This gets maybe a little more obvious with object like this `"Reten. Pol. Allowed Tbl. Impl."`.
And I really don't know who came up with the idea to add dots here. As if it makes it more readable. But it sure wastes another 4 characters. Why not simply `RetenPolicyAllowedTablesImpl`.

Table fields have the same 30 character restriction, which makes it important to not waste chars on spaces there either. But in my practice, I just do `PascalCase` everywhere. Object names, fields names, controls, report columns, variables, procedures. You get the idea.

#### Namespaces

At this point I also need to mention `namespaces`. I am not quite sure in which version this was changed, but as if June 2025 it works for sure. Object names only, you can omit the affix entirely, if the top most namespace is your registered affix.


```AL
namespace STM.SomeNiceExtension.Feature;

table 12345 CustomTable
...
```

In all other places (fields, controls, public procedures etc.) the affix will still be required. But you can rely on the `AppSourceCop` to remind you about the affixes.

> ⚠️ Its important to have at least two levels of namespaces.

## 6. CodeCop Configuration

Static code analysis is one of the easiest ways to enforce consistency and catch issues early — but only if it’s properly configured. A clean codebase isn’t just about style; it also directly affects maintainability, review quality, and AppSource readiness.

### Enable All Relevant Analyzers

In your `.vscode/settings.json`, enable the following AL analyzers:

- `CodeCop`
- `AppSourceCop`
- `PerTenantExtensionCop`
- `UICop`
- `LinterCop`

These analyzers each validate specific areas of your code, such as object naming, field ordering, UI consistency, and AppSource rules compliance.

### Why Both AppSourceCop and PerTenantExtensionCop?

It may seem redundant to enable both `AppSourceCop` and `PerTenantExtensionCop`, but they serve **different purposes**:

- `AppSourceCop` ensures your code complies with AppSource submission requirements (e.g., affix usage, namespace policies, and public interface hygiene).
- `PerTenantExtensionCop` ensures your extension is safe and upgradeable within a single tenant environment — enforcing practices like not overstepping platform boundaries.

Even if you're building a PTE today, having `AppSourceCop` active helps future-proof your code in case you want to convert it to an AppSource app later. Enabling both gives you the full picture and a more stable product.

For example, there is no rule in the `PerTenantExtensionCop` to warn you about missing affixes on extensions objects adding controls to pages or columns to reports.
Its Rule [AS0098](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0098) that takes care about that. But its only in the `AppSourceCop`, yet, this can also break PTEs.

Hopefully you never saw an email like this. It's the perfect example.

![](/images/CouldNotUpgrade.png)

The extension added a new field to the `Posted Purchase Credit Memo` Card, and used the same naming convention like Business Central without any affix. The result, now Microsoft added that "missing" field themselves, and they win. The PTE needs to change. The `PerTenantExtensionCop` will not warn you about missing affixes like this.

> ⚠️ To make the `AppSourceCop` actually work, you need to have a `AppSourceCop.json` config file next to each `app.json` file. So within each project. If that file does not exist, you wont get warnings about missing affixes.

This is the minimal configuration:

```json
{
    "mandatorySuffix": "OVABC"
}
```

### Use a Ruleset to Balance the Two

Of course not all rules make sense for both scenarios, you don't need all AppSource rules for PTE development and vice versa. To solve this I created `external rulesets`

[https://github.com/StefanMaron/RulesetFiles](https://github.com/StefanMaron/RulesetFiles)

I have a base ruleset to change rules for both cases, and one ruleset build on top of the base ruleset for both scenarios.
In a project directly, my ruleset just looks like this:

```json
{
    "name": "Custom",
    "description": "Description",
    "includedRuleSets": [
        {
            "action": "Default",
            "path": "https://raw.githubusercontent.com/StefanMaron/RulesetFiles/main/pte.rulset.json"
        }
    ],
    "rules": []
}
```
To make this work its important to have this setting in one of the settings files turned on `"al.enableExternalRulesets": true`.

### Enforce in CI

With custom rulesets you can also enforce certain rules while not messing with the development experience too much. If you configure your pipelines to use a separate ruleset you can switch selected rules to errors, while during development those will just be warnings. If you where to use the "more strict" ruleset during development as well, it might get annoying if every warning will prevent you from compiling.

## 7. AL-Go Configuration

AL-Go for GitHub is Microsoft’s official DevOps framework for AL projects, designed to automate building, testing, and deploying your apps. If you're serious about quality and long-term maintainability, setting up AL-Go early in your project is a must.

[https://github.com/microsoft/AL-Go](https://github.com/microsoft/AL-Go)

Of course there are different DevOps solution. But since I am using AL-Go for myself I can not confidently talk about and explain those. 

### Why Use AL-Go?

AL-Go provides:

- Automated pipelines for build, test, sign, and publish
- Templates for AppSource apps and PTEs
- Integrated telemetry
- Branch-based configurations for multi-version management
- Built-in support for AppSource and Per-Tenant apps

By using AL-Go, you're aligning with how Microsoft itself structures its internal pipelines — making your app much easier to maintain and prepare for AppSource.

### Setup Recommendations

- Start your project from an AL-Go template repository (Microsoft provides templates).
  - Choose either [https://aka.ms/algopte](https://aka.ms/algopte) or [https://aka.ms/algoappsource](https://aka.ms/algoappsource)
- Configure the necessary secrets early (e.g., for code signing, artifact storage, telemetry keys).
- Customize the `.github/workflows` to match your build and validation requirements.
- Define the runtime, and application version in `app.json` and pipeline config files.
- Don't forget to set the `ruleset` in the AL-Go config file. It's important to also enable `enableExternalRulesets` here

Example config from my projects:

```json
{
  "country": "us",
  "appFolders": ["Customizations"],
  "testFolders": ["Customizations.Test"],
  "appSourceCopMandatoryAffixes": [
    "OVABG"
  ],
  "enableAppSourceCop": true,
  "enableExternalRulesets": true,
  "rulesetFile": "custom.ruleset.json",
  "environments": [
    "DevCustomer",
    "ProductionCustomer"
  ],
  "DeployToDevCustomer": {
    "EnvironmentName": "Dev",
    "ContinuousDeployment": true
  },
  "DeployToProductionCustomer": {
    "EnvironmentName": "Production",
    "ContinuousDeployment": false
  },
  "repoVersion": "1.2"
}

```

On top of that, you can have an organization wide settings variable specified to make the project setup easier.

`ALGOORGSETTINGS`
```json
{
    "runs-on": "ubuntu-latest",
    "conditionalSettings": [
        {
            "workflows": [
                "Update AL-Go System Files"
            ],
            "settings": {
                "workflowSchedule": {
                    "cron": "1 1 * * SAT"
                }
            }
        },
        {
            "workflows": [
                "Test Current"
            ],
            "settings": {
                "workflowSchedule": {
                    "cron": "30 8 * * 5"
                }
            }
        },
        {
            "workflows": [
                "Test Next Minor"
            ],
            "settings": {
                "workflowSchedule": {
                    "cron": "5 8 * * SAT"
                }
            }
        },
        {
            "workflows": [
                "Test Next Major"
            ],
            "settings": {
                "workflowSchedule": {
                    "cron": "0 8 * 2,3,8,9 SAT"
                }
            }
        }
    ],
    "enableCodeCop": true,
    "enableUICop": true,
    "enableAppSourceCop": true,
    "cacheKeepDays": 8,
    "artifact": "//*//",
    "vsixFile": "preview",
    "customCodeCops": [
        "https://github.com/StefanMaron/BusinessCentral.LinterCop/releases/latest/download/BusinessCentral.LinterCop.AL-PreRelease.dll"
    ],
    "alDoc": {
        "continuousDeployment": true
    },
    "keyVaultCodesignCertificateName":"<redacted>",
    "keyVaultName": "<redacted>"
}
```

I think all the settings make at least some sense. Its scheduling certain actions to automatically test and making sure all the cops are active.

`NextMajorSchedule` is configured to only run in February/March and August/September to test the upcoming version. Im my opinion it does not make much sense to test the NextMajor versions too early.

`artifact` Please check the documentation about this setting, you might want to have it configured differently. What this means is, that my `CI/CD` build always runs against the `Application` version specified in the `app.json` I found this the better way of handling PTEs. If the customer does not upgrade directly my CI/CD wont fail if there is a problem on the most recent version. The `TestCurrent` pipeline will still run against the most recent version showing me there is an issue.

## Final Thoughts

Setting up your Business Central app project correctly from the very beginning isn’t just about ticking boxes — it’s about building a maintainable, testable, and future-proof product. Whether you're building for AppSource or creating a solid PTE, following modern best practices like:

- starting from a clean, well-structured template,
- using AL-Go for GitHub for automated pipelines,
- enforcing both AppSourceCop and PerTenantExtensionCop, and
- applying consistent naming and ruleset enforcement

...will save you hours (or days) of rework down the road.

Even if you’re “just getting started,” invest the extra time now to set the right foundation. Future you — and your teammates — will thank you.