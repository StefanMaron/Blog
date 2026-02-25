---
title: "MsDyn365BC.Code.History Tips & Tricks"
date: 2024-10-19T09:00:00+02:00
draft: false
tags: ['Videos', 'Business Central', 'AL', 'GitHub']
---

If you've ever tried to search for something in the [MsDyn365BC.Code.History](https://github.com/StefanMaron/MSDyn365BC.Code.History) repository directly on GitHub, you've probably noticed it stopped working. The GitHub code search just returns no results. You can [watch the full stream on YouTube](https://www.youtube.com/live/LOflL1nztrg) if you want to follow along.

[![GitHub code search returning no results for "Customer" in the repository](/images/msdyn365bc-code-history-tips-tricks/01-github-search-broken.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=138)

The fix is simple: open the repository in the browser-based VS Code instead. Just navigate to the repo and press `.` on your keyboard — or change `github.com` to `github.dev` in the URL. That opens VS Code in your browser with the full repository loaded.

> **📖 Docs:** The github.dev editor is documented in the [GitHub Docs](https://docs.github.com/en/codespaces/the-githubdev-web-based-editor). Note that not all VS Code extensions work in the browser — only those built as web extensions. The AL language extension doesn't support the browser, so you won't get syntax highlighting, but searching and diffing work fine.

## Switching to the right branch first

One important thing: the `master` branch doesn't contain any BC code. It only holds scripts and workflow files. You need to switch to a version branch like `w1-25` first. Do that on GitHub's branch switcher before pressing `.`, and VS Code will inherit the correct branch.

Once you're on a code branch, the full-text search works well. It needs a moment to index on first use, but after that it's fast.

[![VS Code browser showing full-text search results for "Vendor" across all files in the w1-25 branch](/images/msdyn365bc-code-history-tips-tricks/02-vscode-browser-search.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=322)

The search supports regex, case sensitivity, and whole-word matching. There's also a handy "collapse all" button to hide individual match lines and just see the file list — I use that a lot. You can also open the results as an editor tab if that's more comfortable.

For searching by filename rather than content, Ctrl+P is your friend. It does fuzzy matching across the full path, so you can type parts of a folder name and a filename separately and it will narrow things down.

## Looking at what changed in a file

Once you've opened a file in browser VS Code, the **Timeline** view at the bottom of the file explorer shows all the commits for that file across the repository history.

[![Timeline panel showing the full commit history for BankAccountLedgerEntries.Page.al, from v23.1 through v24.3](/images/msdyn365bc-code-history-tips-tricks/03-timeline-file-history.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=552)

Click any entry and you see what changed in that particular commit. Click a second entry to get a side-by-side diff between two specific commits.

[![Side-by-side diff view comparing two versions of BankAccountLedgerEntries.Page.al, showing a local variable removal](/images/msdyn365bc-code-history-tips-tricks/04-side-by-side-diff.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=598)

If you want to compare across a larger version gap — say, everything that changed between v22 and v25 for one file — right-click the older commit, choose *Select for Compare*, then right-click the newer one and choose *Compare with Selected*. That gives you all the changes at once in a single diff.

Comparing across branches in the browser version is more limited. If you switch branches, the page reloads and loses your selection. For cross-branch comparisons, you really want a local clone.

## Cloning only what you need

Cloning the entire repository takes a long time and eats disk space because there are ~250 branches. The README documents the recommended approach: clone a single branch with `--single-branch`.

```bash
git clone -b w1-25 --single-branch https://github.com/StefanMaron/MSDyn365BC.Code.History
```

[![Terminal showing the git clone command completing, cloning only the w1-25 branch](/images/msdyn365bc-code-history-tips-tricks/05-git-clone-single-branch.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=828)

That's much faster. You can always add more branches later without re-cloning. If you want to go further, the README also documents a shallow clone option using `--depth` to limit how many commits you pull — useful if you only care about recent versions.

> **💡 Added context:** `--depth` implies `--single-branch` unless you also pass `--no-single-branch`. So `git clone -b w1-25 --depth 50 --single-branch ...` gives you the last 50 commits on that branch only. You can deepen it later with `git fetch --deepen 50`. See [git-clone docs](https://git-scm.com/docs/git-clone) for details.

> **📖 Docs:** The full list of clone options and branch management commands is in the [repository README](https://github.com/StefanMaron/MSDyn365BC.Code.History#readme).

## GitLens for comparing entire version ranges

Once you have a local clone, the [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) extension becomes very useful. The Source Control Graph shows every commit on the branch — not just the commits for a specific file.

[![GitLens installed and showing the full commit graph for the w1-25 branch with all minor version commits listed](/images/msdyn365bc-code-history-tips-tricks/06-gitlens-commit-graph.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=966)

From there you can right-click a commit, *Select for Compare*, then pick another commit and *Compare with Selected*. This gives you a full diff between two BC versions across all changed files at once. It's heavier than looking at one file — comparing v24 to v25 means processing thousands of file changes — so be ready for it to be slow, especially in a VM.

## Adding more branches with wildcards

To compare across localizations or add a specific country branch, you don't need to re-clone. You can add branches individually:

```bash
git remote set-branches --add origin de-24
git fetch
```

Or use wildcards to pull multiple branches at once. The `git remote set-branches` command only lets you add one at a time, but you can edit `.git/config` directly:

```bash
code .git/config
```

[![.git/config file open in VS Code showing wildcard fetch rules for w1-* and de-* branches](/images/msdyn365bc-code-history-tips-tricks/07-git-config-wildcards.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=1426)

In that file, under `[remote "origin"]`, each `fetch` line controls which branches get pulled. Change them to wildcards like `+refs/heads/w1-*:refs/remotes/origin/w1-*` and then `git fetch` will download all matching branches. To remove branches later, delete the fetch line, delete the local remote reference with `git branch -d -r origin/branch-name`, and optionally delete the local branch if you had it checked out.

## The Sandbox repository and v-next branches

The [MsDyn365BC.Sandbox.Code.History](https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History) repository works the same way but includes `vNext` branches — these track the Insider artifacts and update every day via GitHub Actions. So you can see what's already changed in the upcoming minor release before it ships.

The commit order in `vNext` branches isn't always sequential, because Microsoft releases hotfixes for older minors alongside the next version. If you see commits from v24.5 mixed in between v25.x commits, that's why — the pipeline just picks up whatever was released in the last 24 hours.

[![Side-by-side diff in the Sandbox repository comparing v-next Customer.Table.al, showing obsoleted fields being removed](/images/msdyn365bc-code-history-tips-tricks/08-vnext-diff-comparison.jpg)](https://www.youtube.com/live/LOflL1nztrg?t=1886)

The practical use case: your client is on v24, Microsoft is about to ship v25, and you want to see exactly what changed in a specific table or codeunit. Clone the sandbox repo, fetch the current and next branches, and compare them.

> **💡 Added context:** Both repositories update automatically via scheduled GitHub Actions workflows (BuildNewCommits and BuildNewCommitsNext), so you don't need to do anything to keep them fresh.

The workspaces Stefan had configured for navigating across branches had also disappeared during a repository restructuring — that's something to restore if you use the local workflow regularly. The README covers the full setup.

---

*This post was drafted by Claude Code from the stream transcript and video frames. The [full stream is on YouTube](https://www.youtube.com/live/LOflL1nztrg) if you want the unfiltered version. (I did read and check the output before posting, obviously 😄)*
