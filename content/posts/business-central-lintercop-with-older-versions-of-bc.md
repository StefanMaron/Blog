---
title: 'Business Central LinterCop with older Versions of BC'
date: Tue, 11 Jan 2022 05:37:14 +0000
draft: false
tags: ['AL Lint', 'Allgemein', 'ALLint', 'BusinessCentral']
---

If you want to run pipelines with the LinterCop, you can use Run-ALPipeline and pass in the path to the LinterCop.dll via the parameter - CustomCops. But when running pipelines for various versions of BusinessCentral you might encounter errors like this:

```
Microsoft.Dynamics.Nav.CodeAnalysis, Version=8.2.8.24543, Culture=neutral, PublicKeyToken=31bf3856ad364e35'(,): warning :  An instance of analyzer http://BusinessCentral.LinterCop.Design.Rule0012DoNotUseObjectIdInSystemFunctions cannot be created from C:\Agent\LinterCop\BusinessCentral.LinterCop.dll : Could not load file or assembly 'Microsoft.Dynamics.Nav.CodeAnalysis, Version=8.2.8.24543, Culture=neutral, PublicKeyToken=31bf3856ad364e35'. The system cannot find the file specified.
```

The reason for this is, that every BusinessCentral image ships with the exact version of the compiler. Meanwhile I can only build the LinterCop against the current version of the compiler. But the good news is, the compiler itsself is backwards compatible. Meaning, you can compile a BC17 for example with the compiler released in December 2021 (BC19.2) without problems.

To configure your pipeline to download the latest compiler from the VS Code Marketplace and use it in the pipeline, you can just add this parameter to your pipeline:

```
-vsixFile (Get-LatestAlLanguageExtensionUrl)
```

This parameter works for Run-AlPipeline and Run-AlValidation

I hope this helps, and happy coding!