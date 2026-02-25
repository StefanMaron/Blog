---
title: "Turning My Coding Streams Into Blog Posts (With a Little Help From Claude)"
date: 2026-02-24T08:00:00+01:00
draft: true
tags: ['Business Central', 'Claude Code', 'AI', 'DevOps']
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

The whole thing runs in one command. I review the draft, fix anything obviously wrong, and push.

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

These are the streams that have been converted so far. I'll keep adding to this list as I
work through the back catalogue.

<!-- TODO: add links as posts are generated -->
