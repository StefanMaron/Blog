---
title: 'Bugfixes for LinterCop Rule LC0015'
date: Wed, 02 Feb 2022 08:00:45 +0000
draft: false
tags: ['AL Lint', 'ALLint', 'Business Central', 'BusinessCentral', 'CleanCode']
---

I just released a new version for the [BusinessCentral.LinterCop](https://github.com/StefanMaron/BusinessCentral.LinterCop).

![](https://stefanmaron.files.wordpress.com/2022/02/image.png)

This rule is similar to the [PTE0004](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0004) from Microsoft which checks for your tables to have a TableData permission set. All the other permissions are not covered.

After some discussion and some thoughts I ended up also including the check for TableData in LC0015. If you dont want to have a double check for this, you can disable PTE0004.

More details can be found in the dedicated docs side for this rule:  
[https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0015](https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0015)

And in the release notes for this version  
[https://github.com/StefanMaron/BusinessCentral.LinterCop/releases/tag/v0.24.0](https://github.com/StefanMaron/BusinessCentral.LinterCop/releases/tag/v0.24.0)