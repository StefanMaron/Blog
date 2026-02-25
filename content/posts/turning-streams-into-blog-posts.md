---
title: "Turning My Coding Streams Into Blog Posts (With a Little Help From Claude)"
description: "How a Claude Code skill converts YouTube coding streams to structured blog posts — auto-extracting captions, screenshots, and doc links for 26 BC stream"
date: 2026-02-24T08:00:00+01:00
draft: false
tags: ['Claude Code', 'AI', 'Business Central', 'DevOps', 'GitHub Actions']
---

I'll be honest: I'm lazy when it comes to writing blog posts. Not lazy about sharing — I try to stream
regularly, push code to GitHub, drop things in the community Discord. But sitting down to write
a structured article about something I just spent two hours live coding? That rarely happens.

The stream *is* the content. I jump on, explain what I'm doing, answer questions live, push
something to GitHub, maybe add chapters via AI later. Done. No editing, no polishing.

The problem is that not everyone wants to watch a two-hour live stream. Some people prefer
reading. And if you want to skim for the specific part you need, a video is the worst format
possible.

So I finally did something about it.

## The Pipeline

I built a small Claude Code skill — `/my-video-to-blog` — that takes a YouTube URL and does
the following:

1. Downloads the auto-generated captions from YouTube (no re-transcription needed if they exist)
2. Downloads the video and extracts ~50 frames at regular intervals, with timestamps burned in
3. Claude reads the transcript, reviews all the frames, picks the most useful screenshots,
   and writes a structured blog post in my writing style
4. As a bonus pass, it searches official docs for anything I mentioned but didn't explain,
   and adds clearly marked callout blocks with links

The whole thing runs in one command per video — or in a batch. To clear the back catalogue, I
had Claude run through all 26 streams sequentially, one sub-agent per video, committing each post
to the repo as it finished. Total wall time: 2h 34m 42s.

![Claude Code session showing "Crunched for 2h 34m 42s"](/images/turning-streams-into-blog-posts/batch-runtime.png)

I came back, reviewed the drafts, fixed a couple of things, and pushed.

It's not perfect — the transcript-based posts lack the back-and-forth of a live stream, and
Claude occasionally fills gaps with context I'd phrase differently. But that's what the review
step is for.

The video stays on YouTube. The blog post is the distilled version. Both exist, both link to
each other.

## Why This Also Helps the BC Community AI Tools

There's a side effect worth mentioning. The community BC intelligence tool
[CentralQ](https://www.centralq.ai) — built by [Dmitry Katson](https://katson.com/about/) —
scrapes blog posts and documentation to answer BC-related questions. It works well for written
content but has trouble with YouTube live streams specifically.

So every blog post generated from a stream is also an improvement to that tool's knowledge
base. Two birds, one pipeline.

## All the Generated Posts

26 posts, covering streams from May 2024 to February 2026. The full back catalogue.

- [Building a Plug & Play Claude Code Dev Container for AL Development](/posts/claude-code-dev-container-al/) — Feb 2026
- [AL Development with Claude Code: A Multi-Agent Workflow](/posts/al-development-claude-code-multi-agent-workflow/) — Jan 2026
- [Is Linux ready for BC Development?](/posts/bc-development-on-linux/) — Feb 2025
- [Building Sentinel: Configurable Telemetry and a Better Alert View](/posts/sentinel-telemetry-card-page/) — Feb 2025
- [AppSource Monetization and Entitlements in Business Central](/posts/appsource-entitlements-business-central/) — Jan 2025
- [Documenting BusinessCentral.Sentinel — AI-Generated Docs, Better Alert Descriptions, and Company Deletion Fun](/posts/businesscentral-sentinel-documentation-stream/) — Dec 2024
- [Building BusinessCentral.Sentinel from Scratch: The First Six Rules](/posts/businesscentral-sentinel-first-rules/) — Nov 2024
- [MsDyn365BC.Code.History Tips & Tricks](/posts/msdyn365bc-code-history-tips-tricks/) — Oct 2024
- [How to use Interfaces in Business Central](/posts/interfaces-in-business-central/) — Oct 2024
- [Continuing the NuGet Installer](/posts/nuget-installer-bc-coding-stream-2/) — Oct 2024
- [Creating a NuGet Installer Extension for Business Central](/posts/nuget-installer-extension-bc/) — Oct 2024
- [How Do Database Transactions Actually Work in Business Central?](/posts/bc-database-transactions-deep-dive/) — Sep 2024
- [LinterCop Development: Fixing LC0068 False Positives and the Sandbox Code History Repo](/posts/lintercop-lc0068-indirect-permissions-fixes/) — Sep 2024
- [Basic Repo Setup with AL-Go](/posts/basic-repo-setup-with-al-go/) — Aug 2024
- [Indirect Permissions in Business Central — What They Are and Why They Matter](/posts/indirect-permissions-bc-stream/) — Aug 2024
- [Table Keys and SQL Indexes in Business Central](/posts/table-keys-and-sql-indexes-in-business-central/) — Jul 2024
- [MSDyn365BC.Ntfy Development Session — Redesigning the BC Push Notification App](/posts/msdyn365bc-ntfy-development-session/) — Jul 2024
- [BCv24 Error Info Wrapper — Backporting the Fluent ErrorInfo API](/posts/bcv24-error-info-wrapper/) — Jul 2024
- [Creating the ErrorInfo Wrapper](/posts/creating-the-errorinfo-wrapper/) — Jul 2024
- [Reviewing Microsoft's AI Test Toolkit PR in BCApps — Guideline Fixes Live](/posts/reviewing-ai-test-toolkit-pr-bcapps-guideline-fixes/) — Jul 2024
- [Write-Off App: AppSource Finishing Touches](/posts/write-off-app-abcsource-finishing-touches/) — Jun 2024
- [Build a Better Way to Catch Errors (Part 2) — Without the Test Framework](/posts/build-better-error-catching-without-test-framework/) — May 2024
- [Build a Better Way to Catch Errors (Part 1)](/posts/build-better-error-catching-part-1/) — May 2024
- [FilterPageBuilder.GetView, Language Bugs, and Adding Spare Brained Licensing](/posts/filterpagebuilder-getview-language-bug-spare-brained-licensing/) — May 2024
- [Building an Automatic Write-Off Tool in AL: Adding Overpayments with an Interface Pattern](/posts/al-automatic-write-offs-overpayments-interface-pattern/) — May 2024
- [Writing Testable AL Code: Building a Write-Off App for AppSource](/posts/al-unit-testing-writeoff-app-appource/) — May 2024
