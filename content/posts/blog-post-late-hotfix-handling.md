---
title: "MSDyn365BC.Sandbox.Code.History - Late Hotfix Handling"
date: 2025-10-02
draft: false
tags: ['Business Central', 'github', 'history', 'versions', 'automation']
---

You might have noticed some divergent branch errors when trying to pull from the [MSDyn365BC.Sandbox.Code.History](https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History) repository lately. I am going to explain what the hell is going on, and how to solve it ;)

# The Problem

As mentioned in [Issue #4](https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/issues/4), tracking changes in the repository was becoming increasingly difficult. Microsoft occasionally releases hotfix versions with version numbers **lower** than already-published versions. For example:

- Version `27.1.40348` gets committed to the repository
- A few days later, Microsoft releases version `27.0.40357` (a lower version number!)
- The old script would just commit this chronologically, creating confusing history

This resulted in:
- Convoluted commit graphs with versions appearing out of semantic order
- Difficulty comparing changes between versions
- Massive diffs from out-of-order commits bloating the repository size
- `git blame` showing versions in illogical order

# What Changed

I modified the automation scripts to detect **late hotfixes** and insert them at the correct position in git history using `git rebase`.

### How it works

When a new version arrives, the script now:
1. Compares it against the current branch HEAD
2. If the incoming version is **lower** than HEAD, it's detected as a late hotfix
3. Parses all existing versions on the branch to find the correct insertion point
4. Checks out the commit this should come after
5. Extracts and commits the hotfix at that position
6. Rebases all subsequent commits onto the new hotfix commit
7. Force-pushes with `--force-with-lease` to update the remote branch

This means:

- Git history now shows versions in proper semantic order
- Repository size is reduced by avoiding massive diffs from out-of-order commits
- Standard git operations like `git log`, `git blame`, and `git diff` work as expected
- The entire process runs automatically in both regular and vNext workflows

# The History Was Rewritten

> ⚠️ **IMPORTANT**: Branch history may be rewritten when late hotfixes are released by Microsoft.

Since this uses `git rebase`, branch history will be **rewritten** when late hotfixes are inserted. This is the same situation as when I previously [updated the OnPrem repository](https://stefanmaron.com/2022/01/07/changes-in-msdyn365bc-code-history/) with new features.

WARNING: Do not try this at home! Ehm.. I mean in your real git repository. :) Rewriting git commits and force pushing them is really bad practice and can be dangerous! But for a read-only tracking repository like this one, the benefits outweigh the trade-offs.

# But How to Fix It?

If you have an existing clone and a branch gets rebased, your local copy will become outdated and `git pull` will fail with "divergent branches" errors.

### Automated Solution

I created convenient scripts to automatically update all your local branches:

**Linux/macOS (one-liner):**
```bash
curl -sSL https://raw.githubusercontent.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/main/scripts/update-branches.sh | bash
```

**Windows (PowerShell one-liner):**
```powershell
irm https://raw.githubusercontent.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/main/scripts/Update-Branches.ps1 | iex
```

Both scripts:
- Automatically detect all your locally tracked branches
- Fetch latest changes from origin
- Reset each branch to match the remote
- Support wildcard patterns and dry-run mode

You can also download and run the scripts locally for more control:
```powershell
# Update all tracked branches
.\Update-Branches.ps1

# Update specific branches
.\Update-Branches.ps1 -branches w1-24,w1-25,de-24

# Update using wildcards
.\Update-Branches.ps1 -branches w1-*

# Preview what would change
.\Update-Branches.ps1 -DryRun
```

### Manual Fix for a Single Branch

Well, the easiest way would be to just delete your local clone and clone it again. But if you have only checked out a few branches and you really want to just reset those, then you can use this command:

```bash
git fetch origin
git checkout <branch-name>
git reset --hard origin/<branch-name>
```

# The README

I tried to explain all the rest in the README of the repository.

https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/blob/main/README.md

Here are some parts I want to highlight:

### Why Rewrite History?

- Maintains correct semantic version order in commit history
- Reduces repository size by avoiding large diffs from out-of-order commits
- Makes version comparison and git blame more intuitive
- This is acceptable for a read-only tracking repository

### Partial Clone

To reduce the size of your local clone you can use those commands to clone only the branches you need:

```bash
git clone -b w1-24 --single-branch https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
```

Or use shallow clones to fetch only recent commits:

```bash
git clone -b w1-24 --depth 1 https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
```

---

I hope these improvements make the repository more useful for tracking BC version changes! If you encounter any issues or have suggestions, feel free to [open an issue](https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/issues).