---
title: 'Fixing AL Language Extension Debugger on Linux with Wayland/Hyprland'
description: "How to fix the empty Call Stack and Variables panel bug in the AL debugger on Linux Wayland/Hyprland by running the language server inside a VS Code Dev"
date: 2025-10-31
draft: false
tags: ['Business Central', 'AL', 'Linux', 'Docker', 'VS Code']
---

Last week I switched my development machine from i3 to Hyprland and immediately ran into a frustrating problem: the AL Language Extension debugger stopped working. Well, not completely - it would connect to Business Central and pause on breakpoints, but the **Call Stack and Variables panels stayed completely empty**. No way to inspect any program state at all.

## The Problem

On my old i3 setup everything worked perfectly. But after switching to Hyprland (Wayland), debugging became impossible:

- ✅ Debugger connects to Business Central
- ✅ Breakpoints trigger correctly
- ❌ **Call Stack panel: Empty**
- ❌ **Variables panel: Empty**

The logs showed this cryptic error:
```
System.IO.EndOfStreamException: MessageReader's input stream ended unexpectedly, terminating.
   at Microsoft.Dynamics.Nav.EditorServices.Protocol.MessageProtocol.MessageReader.ReadNextChunk()
```

I thought this would be a quick fix. Spoiler: it wasn't.

## What I Tried (That Didn't Work)

My first thought was version mismatches. So I:
- ❌ Downgraded AL extension from v17 to v16 to match my old system
- ❌ Downgraded VS Code from 1.105.1 to 1.104.1
- ❌ Installed .NET 8.0.20 (I was missing it initially, but adding it didn't help)

Then I thought maybe it's Wayland causing issues, so I tried:
- ❌ Forcing XWayland mode with `--ozone-platform=x11`
- ❌ Removing all Wayland environment variables
- ❌ Rebooting (multiple times, because why not)

When that didn't work, I went for alternative installations:
- ❌ Flatpak VS Code - wouldn't even display a window on Hyprland
- ❌ Arch OSS build - AL extension not available there
- ❌ Docker with X11 forwarding - AL extension froze when trying to install

At this point I was getting frustrated. Nothing worked!

## Why X11 vs Wayland Matters

Before I get to the solution, let me explain why this is such a big deal. The difference between X11 and Wayland isn't just about graphics - it fundamentally changes how applications communicate.

**X11** (my old i3 setup):
- Been around since 1987, super mature
- Very permissive with IPC and event handling
- Decades of compatibility workarounds baked in

**Wayland** (Hyprland):
- Modern, security-focused
- Stricter sandboxing
- Different event loop implementations
- Each compositor does things slightly differently

The AL Language Server uses **socket-based IPC** for communication between VS Code and the debugger. I discovered (after digging through logs and comparing my old working system) that on Wayland/Hyprland, something in the event handling or socket communication breaks. The Debug Adapter Protocol connections work, but state updates never arrive. That's why the Call Stack stays empty - the data simply never makes it through.

## The Solution: VS Code Dev Containers

After all these failed attempts, I realized I was approaching this wrong. Instead of trying to fix Wayland compatibility, why not just run the AL Language Server somewhere it actually works?

That's when I remembered VS Code Dev Containers. The idea is simple:
- My VS Code UI runs natively on Hyprland (no issues there)
- The AL Language Extension runs inside an Ubuntu container
- They communicate via VS Code Remote protocol - just network, no display server involved!

And it actually worked!

### How to Set It Up

Here's what I did. First, create `.devcontainer/devcontainer.json` in your AL project:

```json
{
  "name": "AL Development",
  "image": "ubuntu:24.04",

  "runArgs": [
    "--network=host"
  ],

  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {
      "version": "8.0",
      "installUsingApt": false
    },
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "installOhMyZsh": false,
      "username": "vscode",
      "uid": "1000",
      "gid": "1000"
    }
  },

  "containerEnv": {
    "DOTNET_CLI_TELEMETRY_OPTOUT": "1"
  },

  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dynamics-smb.al"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },

  "remoteUser": "vscode",
  "postCreateCommand": "dotnet --list-runtimes",
  "shutdownAction": "stopContainer"
}
```

Then install the Remote Development extension:
```bash
code --install-extension ms-vscode-remote.remote-containers
```

Now comes the magic part:
1. Open your AL project in VS Code
2. Press F1 → "Dev Containers: Reopen in Container"
3. Wait for the container to build (first time takes a few minutes)

That's it! VS Code will reopen, but now it's connected to the container.

One small gotcha: The interactive login doesn't work from inside the container, so I had to disable it in my VS Code settings:
```json
{
  "al.useInteractiveLogin": false
}
```

The browser still launches fine for debugging, but authentication needs to be handled non-interactively. Small adjustment, but worth mentioning!

## Does It Work?

Yes! Finally!

✅ **Call Stack panel populated**
✅ **Variables panel shows all my data**
✅ **Full debugging capabilities back**
✅ **Workflow is pretty much the same as before**

I was honestly surprised how well this works. The AL Language Server runs entirely in the Ubuntu container where everything just works, and my VS Code UI on Hyprland communicates with it via network - no display server issues involved at all.

## Bonus Benefits

Funny enough, this setup has some nice side effects I didn't expect:
- **Reproducible environment** - No more "works on my machine" between team members
- **Clean separation** - Container dependencies don't mess with my host system
- **Portable** - Same setup works on any Linux system with Docker

## Alternative: Just Use X11

Now, if you think Dev Containers are overkill, you could also just:
- Install i3 or another X11 window manager
- Log into an X11 session for AL development
- Keep Hyprland for everything else

But honestly, I prefer the Dev Container approach. It feels more future-proof and I don't have to switch window managers.

## Final Thoughts

I spent way too much time on this. But at least now I have working debugging again, and this setup is actually pretty nice once you get used to it.

I also reported this issue to Microsoft with all my diagnostics. Maybe they'll fix it in the AL extension eventually. 
https://github.com/microsoft/AL/issues/8150


Until then, Dev Containers it is!

If you're hitting the same issue on Linux with Wayland, give this a try. Would love to hear if it works for you too!

Note: Everything provided as is, without any warranty :)
