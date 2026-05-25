---
title: "You don't need the base app to run your unit tests"
description: "If your unit tests don't touch the base application, you shouldn't have to carry it. Sub-extensions make that possible — and the performance difference is not subtle."
date: 2026-05-25T00:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'Unit Testing', 'Performance', 'AL-Go']
---

Here is a habit most BC developers have never questioned: we test everything together.
One extension. One container. Full application stack. Every time. 
It works. So nobody asks whether it needs to be this way.

## The problem with carrying dead weight

I was working on a project recently that needed to run unit tests against Business Central. The logic being tested had nothing to do with the base application — no posting routines, no document handling, no Microsoft first-party business logic of any kind.

And yet every pipeline run spun up a full BC container with the base app installed. Not because the tests needed it. Because that is what you do.

The base app sat there. Unused. And the pipeline paid for it on every run.

## The pattern that makes isolation possible

Look at how Microsoft structures the BC application stack in its own repositories. It is not one monolithic extension — it is a set of sub-extensions, each with its own `app.json`, each compiling independently, each claiming a slice of the parent ID range.

![BC Apps repository showing sub-extensions with individual app.json files](/images/unit-tests-without-base-app/bc-apps-sub-extensions.png)

You can apply the same pattern to your own code.

The key is how the AL compiler resolves files. When you point it at a directory, it picks up all AL files within that folder structure and uses the `app.json` at that root. Nested `app.json` files in subfolders are ignored — they are only relevant when you compile from that subfolder directly. This means a sub-extension is a compilation scope, not just a folder convention. Point the compiler at the subfolder and you get a small, isolated build. Point it at the parent and everything compiles together as one extension.

The structure looks like this:

- Inside your **main extension**: a subfolder with its own `app.json` containing the isolated logic. No `application` dependency — only the platform.
- Inside your **test extension**: a matching subfolder with its own `app.json` containing the unit tests that target that logic. This sub-extension declares a dependency on the logic sub-extension — and nothing else.

Compile both subfolders independently and deploy them to a BC container that has no base app installed. The logic sub-extension needs none of it. The test sub-extension only needs the logic sub-extension. The container is as small as it can possibly be.

The tests run clean. The scope of the environment finally matches the scope of what is being tested.

## What this looks like in practice

I implemented this as part of my [BC on Linux](https://github.com/StefanMaron/MsDyn365Bc.On.Linux) project, which runs BC containers on Linux for CI pipelines.

The results across BC 27 and 28:

![Pipeline run times before — 8 to 12 minutes per run](/images/unit-tests-without-base-app/pipeline-before.png)

![Pipeline run times after — under 2 minutes per run](/images/unit-tests-without-base-app/pipeline-after.png)

To make it more concrete — here is the container startup step in isolation. Without the base app:

![BC healthy after 26 seconds](/images/unit-tests-without-base-app/startup-after.png)

With the full application stack:

![BC healthy after 4 minutes 19 seconds](/images/unit-tests-without-base-app/startup-before.png)

The outliers in the matrix numbers are slow artifact downloads from Microsoft's servers — the actual test execution time is gone.

Not because the infrastructure got faster. Because the environment finally matched what was actually being tested.

## Does this scale beyond unit tests?

In principle, yes. Any logic that is genuinely self-contained can be scoped this way. But there are limits.

Microsoft's application stack is itself one large dependency tree. If your extension touches anything in the base app — and most do — you cannot remove it. The approach only applies to code that is architecturally isolated from the start: pure business logic, utility functions, validation rules, things that could theoretically run anywhere.

Unit tests are the obvious starting point because the incentive is immediate and the discipline is already implied by what "unit test" means. If your tests are truly testing a unit, they should not need the entire application stack as their environment.

## Why this is not the default

AL-Go for GitHub does not offer this today. There is no configuration to say "spin up a container without the base app for this test run." The assumption baked into the tooling is that you always want the full stack.

Most partners have never asked for it. Probably because it requires code to be written with genuine isolation in mind from the start, and that discipline has never been the default in BC development. We inherited a model where everything lives in one extension and depends on everything Microsoft ships.

That is not a technical limitation of the platform. It is a habit.

The platform has supported sub-extensions for years. The pattern is right there in Microsoft's own repositories. Nobody applied it to test pipelines because nobody had to — the full stack always worked, and slow pipelines are easy to ignore until they aren't.

## The takeaway

If you have logic that does not touch the base application, structure it as a sub-extension with no application dependency. Write tests for it the same way. Your test pipeline then has a legitimate reason to skip the base app — and a much smaller environment to spin up.

Eight minutes down to under two is not a marginal improvement. It changes how often you run tests and how fast you can iterate.

And it starts with one question nobody usually asks: does this test actually need everything that is installed?
