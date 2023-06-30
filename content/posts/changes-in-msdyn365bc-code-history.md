---
title: 'Changes in MSDyn365BC.Code.History'
date: Fri, 07 Jan 2022 11:48:53 +0000
draft: false
tags: ['Allgemein']
---

Today you may have already noticed something like this if you have a local clone of [MSDyn365BC.Code.History](https://github.com/StefanMaron/MSDyn365BC.Code.History) to use with VS Code. I am going to explain what the hell is going on, and how to solve it ;)

![](https://stefanmaron.files.wordpress.com/2022/01/image-4.png)

### The history was rewritten

I had a couple of recommendations to improve this repository. That includes a .gitignore and some changes of the settings in the workspace files. But since this repo is a bit different compared to "normal" repos, its not that easy to just merge a pull request.

In this case, all branches are used, and potentially, also all commits are used. This means for example, the gitignore file will need to be added to all versions of all countries of all major versions. We are talking about roughly 1800 commits that all need to be rewritten to include that new file.

Thankfully there is a command called "git filter-branch" which lets me rewrite history. A little scripting and 14 hours of waiting later, all branches were updated and force pushed to GitHub

WARNING: Do not try this at home! Ehm.. I mean in your real git repository. :) Rewriting git commits and force pushing them is really bad practice and can be dangerous!

### Git large file storage

Another topic that really was long overdue. Git does not handle large files well. They lead to slow vs code and to long clone times. Full text search also does not benefit from large files.

In this case, base app translation files have about 70 MB each. GitHub shows a warning for every file above 50 MB telling to consider using Git-LFS

In short, git-lfs stores the files in a different "storage" I think and in the normal repo only a pointer is saved. If you dont care about the translation files in you local clone you are good to go. If you want to get the translation files, you need to [install git-lfs](https://git-lfs.github.com/)

I hoped to be able to include this as well this time, but it turns out to be more complicated then I expected. Stay tuned ;)

### But how to fix it?

Well, the easiest way would be to just delete it, and clone it again. Then you dont need any fancy git commands to throw away the "old commits" and pull the new commits I pushed to GitHub.

If you have only checked out a few branches and you really want to just reset those, then you can use this command:

```
git branch --format "%(refname:lstrip=-1)" | %{git checkout $\_; git reset --hard "@{u}"}
```