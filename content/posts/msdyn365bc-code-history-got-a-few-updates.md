---
title: 'MSDyn365BC.Code.History got a few updates!'
date: Wed, 23 Jun 2021 06:00:06 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'BusinessCentral']
---

Over the last few month a collected a few requests to improve or change the MSDyn365BC.Code.History repository. Last weekend I finally managed to address them and since Sunday I rebuild the whole Repository. Today its finally going live:

https://github.com/StefanMaron/MSDyn365BC.Code.History

Include Translation files
-------------------------

Since today, (hopefully) all translation files are included. I never did this but in case you need to, you can now compare them. For performance reasons they are excluded from search in all the workspaces that are part of the repository tho.

Workspace file for all the test folders
---------------------------------------

This one was a bit tricky but I got it working. I collected all the test folders within all apps via PowerShell and generated a workspace file for it. Meaning, you can now open this workspace in every version and get all the test apps at once. This way it is possible for example to search only within test and library apps. (\*.xlf files also excluded)

Bug in the MX localization
--------------------------

A bug in folder naming of the MX localization made the folder undeletable and therefore it was also part of a few other commits.

[Archive Name of MX\_DIOT test app leads to problems on windows · Issue #1973 · microsoft/navcontainerhelper (github.com)](https://github.com/microsoft/navcontainerhelper/issues/1973)

I changed my script to handle this, so even if the problem is not solved yet, it does not affect the repository anymore.

How do I update my local clone?
-------------------------------

Since I rewrote history and rebuild the whole repository, you can not simply pull the latest changes this time.

But this three commands should do the trick and you do not need to clone everything again.

```
git reset --hard "@{u}"
git clean -df
git pull
```