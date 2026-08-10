---
title: "BC on Linux: A Working Web Client, Faster Boots, Local Dev on Mac and Linux, and a Fast Lane in AL-Go"
description: "The web client now works — click-through Business Central development, not just API calls, on Linux or Mac with one command. Plus cold boot down from 209s to 79s, a real production test run at 1,067 tests in 69 seconds, and BC 29 support."
date: 2026-08-10T07:00:00+02:00
draft: false
tags: ['Business Central', 'AL', 'DevOps', 'CI/CD', 'Linux', 'AL-Go', 'Performance']
---

Last time I wrote about [running BC on Linux](https://github.com/StefanMaron/MsDyn365Bc.On.Linux), the improvement was skipping the base app entirely for tests that don't need it. That's still true, but it only helps if your tests are genuinely isolated from the base app — most aren't. Since then the project has moved well past that one trick, and I haven't written about most of it. Here's what's actually there now — and the biggest thing I haven't mentioned yet is that the web client actually works, which changes what this project is for.

## The web client works now — this is local development, not just API testing

Up to now, running BC on Linux meant you got the dev endpoint, OData, and the API — enough to run tests and automate against, but not enough to actually click around in Business Central. That's changed. The browser-based web client runs now, field edits made in the browser persist correctly through to the database, and direct URL navigation (jumping straight to a specific page in edit mode, for instance) works. It restarts itself automatically if it crashes. This is still early — printing and file upload aren't verified yet — but the core, day-to-day flow of opening a page and editing a record works as you'd expect.

That's the difference between a container you can automate against and a container you can actually develop in. Turn it on with one environment variable:

```bash
git clone https://github.com/StefanMaron/MsDyn365Bc.On.Linux.git
cd MsDyn365Bc.On.Linux
BC_WEBCLIENT=1 docker compose up -d --wait
```

No .NET SDK on your host. No Windows. It pulls a prebuilt, public image — nothing to build yourself — and boots a working BC with a demo database, dev endpoint, OData, API, and the test toolkit already published. First boot takes about 5 minutes (downloading and setting everything up); every boot after that is close to a minute. On Apple Silicon it runs through podman with a small compose overlay for SQL Server compatibility — full steps are in the repo's `MacOS.md`, and the web client works there too.

If you've wanted to develop against BC without a Windows VM or a cloud sandbox, this is that.

## Cold boot: 209 seconds down to 79

Even with local dev in mind, boot time still matters most for CI, where you pay it on every run. I found that the container was recompiling the entire Base App from source on every single cold boot, even though I'd already pre-built and cached the compiled version — the cache just wasn't being read from where the service tier actually looks for it. Once I fixed where the compiled assemblies get placed so BC's own cache lookup actually finds them, cold boot time dropped from 209 seconds to 79. That's the whole container, download to ready, not just one internal step.

## Tests: a real production run, 1,067 tests in 69 seconds

Separately, running the tests themselves had its own overhead: the old approach started a fresh process and a fresh connection for every single test codeunit, paying that cost again and again. I built a persistent connection that stays open across an entire test run instead. This isn't a lab number — it's from an actual pull request build on one of my real client projects: 1,067 tests across 151 codeunits, all passing, in 69 seconds total. It's opt-in for now while it gets more real-world use, but the fast path is there and it's already carrying real test suites.

## BC 29 now boots and runs

BC 29 needs a newer .NET runtime than the container previously shipped. It's supported now — the image carries both runtimes and picks the right one automatically. Getting there also turned up two real bugs that were only waiting to happen under the new runtime, both fixed. If you're on BC 29, confirm you're on a current build before relying on this — it only stabilized in the last couple of days.

## Download times: no more 30 seconds or 6 minutes for the same file

Artifact downloads used to be wildly inconsistent — sometimes fast, sometimes six minutes for the exact same file, depending on whether Microsoft's CDN happened to have it cached nearby. Fixed with parallel downloading and automatic retry on stalls. Along the way I also found a bug that was silently dropping a large, genuinely-needed folder from some downloads due to a filename case mismatch — that's fixed too, and it was a correctness bug, not just a speed one.

## AL-Go gets a Linux fast lane for pull requests

None of the above matters to your pipeline unless it's actually running on your PRs. `linuxFastLane` is a new setting in [my AL-Go fork](https://github.com/StefanMaron/AL-Go): turn it on and a project's PR build compiles from source, publishes to a Linux BC container, and runs your AL unit tests — all without a Windows runner, and without the signing/release steps a full pipeline needs. It's meant as a fast pre-check, not a replacement for your release pipeline.

The fork itself is deployed and live — you can point your own repo's `templateUrl` at it today and try `linuxFastLane` with a one-line setting change, and revert just as easily if it's not for you. I want to be precise about adoption, though: right now exactly one real repository of mine runs on it. The rest of my projects are still on stock Microsoft templates. This is "you can use this today," not "everything already runs on it."

## The newest piece: automatic caching, and a 16-second restore

For self-hosted runners and local machines (not GitHub-hosted CI, which always starts from a clean disk), the container now automatically reuses whatever's already on disk from the previous run instead of rebuilding it from scratch: downloaded artifacts, the patched service tier, and compiled assemblies each get their own cache, invalidated only when something that actually matters changes.

On top of that, there's an opt-in snapshot mode, and this one is worth explaining rather than just quoting a number. Normally, every time BC starts, the service process boots from nothing: it loads, it connects to the database, it compiles what needs compiling, and only then does it start actually serving requests. Snapshot mode instead freezes an *already-running, already-serving* BC process to disk — the live process, mid-execution, not just its files — and restoring it means handing that frozen process straight back to the CPU. There's no startup sequence to run through at all, because nothing is starting. It's more like waking a process up than booting one.

On my own machine, that gets BC ready in as little as 16 seconds, against roughly a minute for a normal warm boot. That's measured on my own hardware, it's opt-in, and it only helps self-hosted or local setups — a GitHub-hosted runner starts from a clean disk every time, so there's nothing to restore from.

Two things worth knowing if you try this. First, a snapshot is only valid for the exact combination it was taken under — the same BC version, the same installed apps, the same container image, the same license. Change any of those and the snapshot is invalidated and a fresh one has to be taken; it needs an exact, pinned combination, not a range of acceptable versions. Second, each snapshot is a real, sizable file on disk — a frozen process image, not a small marker — so if you're snapshotting multiple version/app combinations, plan for real disk space, not a negligible amount.

## The takeaway

The biggest win here wasn't a clever optimization — it was noticing that a cache I'd already built wasn't actually being used, because I'd never checked. Populated, present on disk, looking correct, and silently ignored. If you're caching anything in your own pipelines, it's worth checking the same way: not just "is it there," but "is anything actually reading it."
