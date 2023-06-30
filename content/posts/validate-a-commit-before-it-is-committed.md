---
title: 'Validate a commit before it is committed'
date: Thu, 10 Jun 2021 14:20:29 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'BusinessCentral', 'git', 'Powershell']
---

Recently there was this question about how to do version numbering when working with AL Apps and automatic builds:

![](https://stefanmaron.files.wordpress.com/2021/06/image.png)

It started a discussion about when to update which part of the version number and how that is done. The discussion will be continued today (10th June 2021 9pm CEST) on Discord if you are interested to join/listen:

[waldo on Twitter: "For whomever is interested - this Thursday, 9pm CEST, we'll have a discussion on this topic (handling app versions) on the #msdyn365bc discord: https://t.co/UShuaazygh We'll be at the "General" voice channel! When? Thursday, 9pm CEST https://t.co/gD5ya04wR3 Interested? Join!" / Twitter](https://twitter.com/waldo1001/status/1401964172959748104)

But that's not the reason why I write this blog ;)

First, it's important to know what the parts of a version number are called. These terms I will use a lot to explain what I am up to and they are also used if you want to script anything with version numbers in PowerShell.

I have seen people using different terms but (at least I hope so) in the Microsoft world these are the terms used.

The version number consist off four parts which are separated by a single period each.  
The first number is called **"Major",** the second one **"Minor"**, the third one is called **"Build"** and the last one is the **"Revision"** number.

![Visual Studio extensions and version ranges demystified | Visual Studio Blog](https://devblogs.microsoft.com/visualstudio/wp-content/uploads/sites/4/2019/03/version-number-breakdown.png)

In all the projects I do, I use the Major and the Minor number to define manually which version my app currently has. These are just written to the app.json file and committed to the repository. The build and the revision number are always set to zero in the app.json.

The reason for this is, that I have set up automatic builds for all my projects. That means that in a pull request a build runs for every push that is done and if a pull request is merged, a separate build will run again. For all these builds I want to have a unique version number.

To achieve this, I configured my build pipeline to increase the version number at the beginning of every build run. The Revision number is increased by one on every build during a pull request and the build version is increased for every build on the master branch.

But why am I explaining this? Well, to keep the repository clean it is important that the Build and Revision number in the app.json is not changed. It would not have any impact as it is overwritten anyways, but I like to have it clean ;)

### I want to prevent a commit if the version number of an app is not valid

While researching how to solve this problem I came across **git hooks**. With git hooks it is possible to run a command an various actions performend with git.

Official docs to git hooks: [Git - Git Hooks (git-scm.com)](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

For validating my app version I used the **pre-commit** hook. This fires every.single.time you commit anything in the repository. The nice thing about it is, if there happens to be an error, the commit will abort. Meaning you can prevent to commit stuff you need to revert later because the pipeline failed.\\

The default folder for git hooks is **<your\_local\_repo\_path>\\.git\\hooks\\** If you remove the ".sample" part from the files inside, they are activated.

The problem with this path is, that it is not tracked with git itself. Meaning you can not share it with everyone working on this project.

Fortunately the default path can be changed: [https://stackoverflow.com/a/37293090](https://stackoverflow.com/a/37293090)

I ended up using this command as I want to have it identical in every project. If the folder does not exist or is empty, just nothing happens.

```
git config --global core.hooksPath .githooks
```

This command will set the hookspath globally to **<your\_local\_repo\_path>\\.githooks\\** which then committed within the project.

**Important:** This command need to be executed on every machine working with these repositories, fortunately only once.

Within this directory I created the **pre-commit** file. Note that this does not have any file extension like ".txt"

https://gist.github.com/StefanMaron/b9280a2945a725b4c5f83f93383830b4

Because it's easier for me, I decided to just call a PowerShell script and put all the logik there. The PowerShell file you can just put in the same directory.

https://gist.github.com/StefanMaron/29d58eee05fdf32893066bb5494bde3f

In the first line I get every file which is staged. If you do not stage a change there is no need to check it, as it would not be committed anyway. After that, I loop over all the files and handle only the app.json files in any directory. With the command **"git show :$\_"** I get the file content of the file name from the current loop, but with the staged changes applied. This assures that even partial stages are supported.

After that I check the Build and Revision number. If one is not 0 an error is thrown:

![](https://stefanmaron.files.wordpress.com/2021/06/image-1.png)

And that's it 😎

I hope you find this as useful as I do. Feel free to share your use cases and adapt it to whatever rule you need to enforce in repositories.