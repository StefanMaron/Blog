---
title: 'BusinessCentral.LinterCop'
description: "Introducing LinterCop — an AL code analyzer for Business Central built by reverse-engineering the compiler /analyzer: interface. Contribute on GitHub."
date: Thu, 02 Sep 2021 08:13:42 +0000
draft: false
tags: ['Business Central', 'AL', 'LinterCop', 'Code Quality']
---

As you maybe remember, I am working on a linter solution for AL for some time already. I tried a VS Code extension. I tried to build a dll to increase performance and to make it available in powershell and therefore also in pipelines. But for now I did not find a proper solution.

Recently I realized that the AL Compiler has a parameter "/analyzer:" and accepts a dll. And depending on wich cops you enable, the according ddls are just passed in.

I took that chance and reverse engineered the interface a CodeCop.dll needs to implement. The result seems to be a working BusinessCentral.LinterCop:

![](/images/migrated/2021-09-image.png)

![](/images/migrated/2021-09-image-1.png)

### Call for community Help!

I am not a C# developer ;) But I am sure some of you can mangle some C# code quite good!

Please get involved and help me to make an awesome tool for the #msdyn365bc community. Does not matter if you write pull requests, review code, or you just submit a few issues with linter checks you feel missing.

You can follow the current state of the project on my GitHub:

https://github.com/StefanMaron/BusinessCentral.LinterCop