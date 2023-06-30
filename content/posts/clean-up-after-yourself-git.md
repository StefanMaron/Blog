---
title: 'Clean up after yourself, Git!'
date: Wed, 10 Mar 2021 07:00:30 +0000
draft: false
tags: ['git', 'Powershell']
---

You may know this problem: After a while working with feature branches your local git repository is a mess of many branches which don't event exist anymore on your remote. (GitHub/GitLab/DevOps)

You could delete these local branches manually but if you are as lazy as I am, you might want to read on and just take my solution for this ;)

I wrote a short function in PowerShell which cleans up branches for me:

```
function Remove-MergedGitBranches {
    git remote prune origin
    git branch -vv | where { $\_ -match '\\\[origin/.\*: gone\\\]' } | foreach { git branch -D ($\_.split(" ", \[StringSplitOptions\]'RemoveEmptyEntries')\[0\]) }
}
```

The first line removes references to remote branches that do not exist anymore, from your local git. Note: If your remote is not named "origin" you may want to change that.

The second line gets all local branches and checks if the related remote branch is "gone". If so, the branch is deleted.

Now, how to make this always available?

I like to do PowerShell in VS Code. If you prefer a different editor you need to adjust the following commands.

PowerShell Profile
------------------

When you type **$profile** in a PowerShell console, you can get the path to your PowerShell profile. This profile is loaded every time you open up a new shell. So every function you paste in this file, will be always available ;)

![](https://stefanmaron.files.wordpress.com/2021/03/image-2.png)

To open this file up in vs Code you can use the **code** shortcut in the shell:

![](https://stefanmaron.files.wordpress.com/2021/03/image-3.png)

If you already have an open VS Code window, the file will just be opened in a new tab, if not a new window will be opened.

You can just paste the function in there:

![](https://stefanmaron.files.wordpress.com/2021/03/image-4.png)

Save it and start up a new PowerShell session. Then you can just use the function like this:

![](https://stefanmaron.files.wordpress.com/2021/03/image-5.png)

Note: If there is nothing to delete, you wont see any output. Otherwise it shows which branches where deleted.