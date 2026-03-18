---
title: "Swappable Claude Profiles: Per-Project Configs via Container Mounting (Part 3)"
description: "How to give Claude Code a completely different 'brain' depending on what you're working on — by mounting self-contained profile folders into the container instead of sharing a single global config."
date: 2026-03-16T09:00:00+01:00
draft: false
tags: ['Videos', 'Claude Code', 'Docker', 'Business Central', 'AL', 'Dev Containers', 'AI']
---

After [Part 2](https://stefanmaron.com/posts/claude-code-dev-container-al/) we had a working standalone container — no VS Code required, no IPC socket surprises. But there was still one problem: a single global `~/.claude` folder shared across everything. One set of instructions, one list of skills, one set of agents — regardless of whether you're doing AL development, debugging telemetry, or investigating something completely different.

That doesn't scale. So this part introduces profile folders.

You can [watch the full stream on YouTube](https://www.youtube.com/watch?v=LuAHCXiwYn4) if you want to follow along.

## What a profile folder is

A profile folder is just a regular directory on your host machine. It contains everything Claude Code normally stores in `~/.claude`:

- A `CLAUDE.md` with context and instructions specific to this kind of work
- A `commands/` directory for slash commands
- An `agents/` directory for custom subagents
- A `plugins/` directory for marketplace plugins
- `settings.json`, `history.json`, and the rest

[![The AL Development profile folder — CLAUDE.md open with the full file tree visible on the right](/images/swappable-claude-profiles-container-mounting-part-3/01-al-profile-folder-structure.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=150)

The key difference from the previous setup: I'm no longer persisting the Claude config into a Docker volume. Instead, I keep these profile folders directly in my home directory, wherever I want. One for AL development, one for telemetry investigation, one for whatever else comes up.

## Mounting a profile

The container launch command grew one new `-v` line:

```bash
docker run -it --rm \
  --cap-add=NET_ADMIN --cap-add=NET_RAW \
  -v "$HOME/claude-al-development:/home/vscode/.claude" \
  -v "claude-code-data:/home/vscode/.local/share/claude" \
  -v "$(pwd):/workspaces/project" \
  claude-code-sandbox
```

The first volume mount is the only thing that changed. The AL development profile folder gets mapped to `/home/vscode/.claude` inside the container. Claude Code inside sees it as its home config. It has no idea it's one of several swappable configs — it just works.

[![README showing the docker run command with the profile volume mount highlighted](/images/swappable-claude-profiles-container-mounting-part-3/02-docker-run-profile-mount.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=350)

Switch profiles by changing that one `-v` line. Same container image, completely different Claude.

## Verifying it works

The profile includes a `/hello` command (a simple markdown file in `commands/`). Running it inside the container immediately confirmed the mount:

```
Hello from the AL development config folder! Custom commands are working.

Let me list the contents of ~/.claude/ to confirm the host folder is mounted.

The host folder is mounted and accessible. Key contents:
- CLAUDE.md — Global instructions file (AL development config)
- commands/ — Custom commands directory (where /hello-al lives)
- settings.json — Claude Code settings
- projects/ — Project-specific configurations
- plugins/ — Plugin directory
- Plus various internal files (credentials, history, debug logs, etc.)

Everything is working correctly!
```

[![Claude confirming the AL profile is mounted and accessible, showing all folders and files](/images/swappable-claude-profiles-container-mounting-part-3/03-hello-from-al-profile.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=400)

## Agents get saved into the profile

This is where it gets interesting. I created a new agent directly inside the running container — an AL repo summarizer, designed to give a human-readable overview of any AL project without having to read every single line of code.

Claude Code offers two scopes when creating an agent: *Project* (saved to `.claude/agents/` in the current project) or *Personal* (saved to `~/.claude/agents/`). Inside the container, `~/.claude` is the mounted profile folder. So the "personal" agent goes directly into the AL profile on the host.

[![The al-repo-summarizer agent was created and automatically saved into the AL Development Config profile folder](/images/swappable-claude-profiles-container-mounting-part-3/04-agent-created-in-profile.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=600)

I immediately used it on the Sentinel project. After running for a couple of minutes, the agent produced a structured summary — extension metadata, architecture highlights, notable observations. But the part that surprised me most was that it also wrote its own memory:

[![The agent-written MEMORY.md with detailed AL patterns, job queue integration notes, and project analysis](/images/swappable-claude-profiles-container-mounting-part-3/05-agent-memory-al-patterns.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=700)

The agent built up a MEMORY.md inside the profile with AL-specific patterns it discovered — telemetry patterns, setup table structure, performance notes. That memory persists in the profile. Next time you point the container at this profile and run that agent on any AL project, it has prior context to draw from.

## Switching to a different profile

To show the concept more concretely, I switched to a different project and a different profile — a minimal `bc-telemetry` folder with almost nothing in it. Same launch command, just two changes: the project directory and the profile mount.

Because credentials are stored inside the profile folder too, switching means Claude Code asks you to log in again. In practice you could carry the same credentials across profiles if you wanted, but separate auth is actually useful if you're running different accounts or want true isolation.

[![The VS Code workspace showing both the AL Development Config and Telemetry profile folders side by side](/images/swappable-claude-profiles-container-mounting-part-3/06-two-profile-workspaces.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=800)

The telemetry profile had a plain `CLAUDE.md` and nothing else. A blank slate to build context for that specific type of work — connect Waldo's MCP server, add telemetry-specific instructions, that kind of thing. You build the profile once and then load it into any folder you're investigating.

## Skills vs Commands

Toward the end of the stream I went down a rabbit hole on skills. I'd been using commands (simple `.md` files invoked with `/name`) for everything. But Claude Code's current standard is *skills*, following the [Agent Skills open standard](https://agentskills.io).

I asked Claude to explain the difference, and it pulled the documentation and produced a clear comparison:

[![The Commands vs Skills comparison table Claude generated from the documentation](/images/swappable-claude-profiles-container-mounting-part-3/07-commands-vs-skills-table.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=1500)

The short version: commands are a single `.md` file. Skills are a directory with a `SKILL.md` and optional supporting files. The important additions in the skills frontmatter:

```yaml
---
name: my-skill
description: Used by Claude to decide when to auto-invoke
disable-model-invocation: true   # manual /slash only
allowed-tools: Read, Grep        # restrict available tools
model: opus                      # override model
context: fork                    # run in isolated subagent
---
```

[![SKILL.md frontmatter showing all options including context: fork for isolated subagent execution](/images/swappable-claude-profiles-container-mounting-part-3/08-skill-frontmatter-fork.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=1700)

The `context: fork` option runs the skill in a completely isolated subagent. The skill content becomes the subagent's system prompt. It won't have access to the current conversation history — which is exactly what you want for something like a compile or publish step that should behave consistently regardless of conversation state.

> **📖 Docs:** The full skills reference including frontmatter fields, supporting files, and `context: fork` behavior is at [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills).

> **💡 Added context:** Agent Skills is an open standard adopted across multiple AI coding tools — Claude Code, Cursor, GitHub Copilot, Gemini CLI, and others. A skill you write for Claude Code will also work in other skills-compatible tools without modification. See [agentskills.io](https://agentskills.io) for the spec and the full list of adopters.

[![Claude Code Docs showing the "Run skills in a subagent" section with the context: fork explanation](/images/swappable-claude-profiles-container-mounting-part-3/09-docs-run-in-subagent.jpg)](https://www.youtube.com/watch?v=LuAHCXiwYn4&t=2100)

## What's next

My existing AL development profile was built around commands and subagents configured manually. Migrating it to proper skills — with the right frontmatter, tool restrictions, and `context: fork` where appropriate — will change how it all fits together. That's not something I want to do live on stream; it mostly involves having a long conversation with Claude about system design. But the result will be a proper published AL development profile you can use as a starting point.

The container image itself is stable at this point. If you want to start building your own profiles now, the repo is at [StefanMaron/claudeCodeAlDevContainer](https://github.com/StefanMaron/claudeCodeAlDevContainer). Issues welcome — I'll find some of the rough edges myself too.

---

*This post was drafted by Claude Code from the stream transcript and video frames. The [full stream is on YouTube](https://www.youtube.com/watch?v=LuAHCXiwYn4) if you want the unfiltered version. (I did read and check the output before posting, obviously 😄)*
