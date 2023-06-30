---
title: 'Updates on my LinterCop project'
date: Wed, 17 Nov 2021 06:20:47 +0000
draft: false
tags: ['Allgemein', 'ALLint', 'BusinessCentral']
---

In the last days, I managed to get some new updates for you released. Since this would be too much for a tweet, I will summarize here what changed, what will change in the next days (hopefully 🙃 ), and what is planned for future updates.

### What changed lately?

##### P**ipelines and automated builds**

The biggest change I did in the last weeks, was to introduce pipelines and automated builds on GitHub for the LinterCop. This looks like a minor task, but I was not familiar with GitHub Actions, and needed to dig into it first.

I had several problems at the beginning: How to compile dotnet with the command line? How to run the build on a hosted agent? Linux or Windows build agents? How to get the dependencies? And others.

But in the end, I managed to get it running. If you are interested, you can see the result here on [my GitHub](https://github.com/StefanMaron/BusinessCentral.LinterCop/actions)

##### U**pdates for Rule0005**

Next was to work on some issues, resulting in updates for Rule0005 which checks for case mismatching. Previously it only warned on wrong casing in code, like field names or function names.

Now it checks (almost) everything in code. Meaning every keyword in object definitions and code.

See for yourself:

![](https://stefanmaron.files.wordpress.com/2021/11/fdx-yqfxsaayjtv.png)

##### **New rule for "NotBlank" property on primary** **key fields**

Last but not least, I introduced a new rule which checks for "NotBlank" property on primary key fields if it is of type code or text and the only field in the primary key. For example the No. field on customers. For more details read [here](https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0013).

### Next topics

##### Pre-releases and beta testing

While working on those changes, I realized (and also some users [#94](https://github.com/StefanMaron/BusinessCentral.LinterCop/issues/94)) that I will need the possibility to do pre-releases and beta testers. The plan is to do some more enhanced branching and to adjust the build pipeline to create pre-releases from a certain branch.

Also the [vs code extension](https://marketplace.visualstudio.com/items?itemName=StefanMaron.businesscentral-lintercop) will need an extra setting to auto load those pre-releases for anyone who wants to support me with testing those new features.

##### Analyzer selector in VS Code

This is currently work in progress. I plan to implement an indicator in the bottom line of vs code showing you which analyzers are currently active. Especially when working on multiple projects and if settings are spread over user, workspace and folder wide settings, this will help.

Also there will be the possibility to open a select menu for analyzers, when clicking on the indicator. This helps to add analyzers to the active setting file with only a few clicks.

### Backlog

The backlog of rules which could be implement can be found in the [discussions](https://github.com/StefanMaron/BusinessCentral.LinterCop/discussions?discussions_q=-label%3AResolved+sort%3Atop) part on GitHub.

Here are the first three most voted ideas as of today:

[Lookup Flowfields - perform Calcfields upon validating it's parent field #65](https://github.com/StefanMaron/BusinessCentral.LinterCop/discussions/65)

[Validate field length against TableRelation #41](https://github.com/StefanMaron/BusinessCentral.LinterCop/discussions/41)

[Mandatory CaptionClass (vs Field patterns) #80](https://github.com/StefanMaron/BusinessCentral.LinterCop/discussions/80)

If you follow this project and plan to use the LinterCop in your projects you may want to have a look at other ideas as well, and vote for the ones you would like to be implented.

If you have any other ideas which are not yet listed, feel free to create a new discussion for it!