---
title: 'BusinessCentral.LinterCop v0.23.0'
date: Wed, 05 Jan 2022 07:10:45 +0000
draft: false
tags: ['Allgemein']
---

A new version of the [BusinessCentral.LinterCop](https://github.com/StefanMaron/BusinessCentral.LinterCop) just got released 🥳

Special thanks to Rob van Bekkum [@rvanbekkum](https://twitter.com/rvanbekkum) who wrote two new rules!

![](https://stefanmaron.files.wordpress.com/2022/01/image.png)

### Added Help links to wiki

Microsoft already did this in the december release I think, and now the LinterCop also includes direct links to the wiki on GitHub.

![](https://stefanmaron.files.wordpress.com/2022/01/image-1.png)

Just by clicking for example on "LC0015" you can open the wiki page for this rule on the GitHub Repository [https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0015](https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0015)

You can also manually browse the wiki pages for the rules by going to "Wiki" on the [repository](https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki)

![](https://stefanmaron.files.wordpress.com/2022/01/image-2.png)

The rules are described at a minimum right now. If you have any questions about a certain rule, feel free to start a [discussion](https://github.com/StefanMaron/BusinessCentral.LinterCop/discussions) and I will answer it and also update the wiki later on.

### LC0014: The Caption of permissionset objects should not exceed the maximum length.

I think this should be quite self explanatory. However, this rule checks if the caption of permissionset object does not exceed the maximum length of 30 characters. It also checks if maximum length is set in order to show the person translating that only 30 chars are allowed.

### LC0015: Permission Set Coverage

This rule checks if all objects are covered by at least one permission set. The rule [PTE0004](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0004) of the per tenant extension cop does a similar check, but only for table object. LC0015 checks all object types.

If you do not have the vs code extension yet, go to the [marketplace](https://marketplace.visualstudio.com/items?itemName=StefanMaron.businesscentral-lintercop) to get it now ;)