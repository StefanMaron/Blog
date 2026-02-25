---
title: 'BusinessCentral.LinterCop goes VS Code!'
description: "Install LinterCop in VS Code for AL development — the auto-updating extension adds custom code analysis rules via your al.codeAnalyzers settings."
date: Tue, 21 Sep 2021 15:59:09 +0000
draft: false
tags: ['Business Central', 'AL', 'LinterCop', 'VS Code', 'Code Quality']
---

After quite some analyzing and reverse engineering, I got it working!

![](/images/migrated/2021-09-image-2.png)

The custom code analyzer BusinessCentral.LinterCop is running included in VS Code.

### And here is how to do it:

First, go to my GitHub and download the latest binary [here](https://github.com/StefanMaron/BusinessCentral.LinterCop/releases).  
Then just place it on your hard drive, for example "C:\\ALCustomCops\\"

![](/images/migrated/2021-09-image-3.png)

Then go to your settings file and insert it in the "al.codeAnalyzers" like this:

![](/images/migrated/2021-09-image-4.png)

And thats it! Pretty short Blog but this should get you going ;)

If you encounter any problems or want to contribute with new rules, please go to my GitHub and submit issues!

[https://github.com/StefanMaron/BusinessCentral.LinterCop](https://github.com/StefanMaron/BusinessCentral.LinterCop)

**EDIT:**

I got some nice feedback from the community pointing out that this process of manual installation probably wont work for any kind of real usage scenario. Every time the linter gets an update a manual download would be needed.

To solve this, I created a small [VS Code extension](https://marketplace.visualstudio.com/items?itemName=StefanMaron.businesscentral-lintercop&ssr=false#overview)!

![](/images/migrated/2021-09-image-5.png)

This extensions provides auto updates for the BusinessCentral.LinterCop.

By default the extension checks if the dll is still there (and did not get deleted due to updates of the AL Extension) and if a new version is released. If one case is true, the latest version of the dll will be downloaded.

The dll will be placed directly into the Analyzers folders inside the folder from the AL extension. Therefore the setting changes slightly:

In order to activate the LinterCop you need to add this line `"${analyzerfolder}BusinessCentral.LinterCop.dll"` to the `"al.codeAnalyzers"`. For example like this:

```
"al.codeAnalyzers": [
    "${CodeCop}",
    "${UICop}",
    "${analyzerfolder}BusinessCentral.LinterCop.dll"
],
```

Lets build an awesome Linter Cop!