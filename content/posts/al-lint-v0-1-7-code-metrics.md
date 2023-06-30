---
title: 'AL Lint v0.1.7: Code Metrics'
date: Tue, 11 Aug 2020 06:09:23 +0000
draft: false
tags: ['AL Lint', 'ALLint', 'CleanCode']
---

This morning I updated the code metrics calculation in AL Lint. Code metrics are meant to give you some comparable numbers on how complex your code is.

Why is this important information?

In general, if you install this extension, you aim for clean code. This is because code is written once but probably is read multiple times. And the easier it is to understand the more time you will save while reading your code. And probably even others will read your code and they will a hard time understanding what you did if the code is a mess!

So with code metrics you have a clear number which tells you if your code got too complex and you should see if it could be refactored.

They are now displayed in the bottom line of VS Code

![](https://stefanmaron.files.wordpress.com/2020/08/image-12.png)

#### Cyclomatic Complexity

This code metric simply counts the number of your "if", "else" and "case" cases per function. So the number displays the number of possible ways your code can go. Or, the number of tests you would need to write to cover this function completely.

I searched for an English article on this one, but the best one I have found is the German Wikipedia article on this topic: [McCabe-Metrik](https://de.wikipedia.org/wiki/McCabe-Metrik) (German), [Cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity) (English)

In general you want to have your Cyclomatic Complexity **less than 10 for every function.**

#### Maintainability Index

The Maintainability Index gives you insight on the overall maintainability of your function. This is more than just logical complexity but more like overall complexity of the code.

This metric is calculated from many numbers. It covers Cyclomatic Complexity, lines of code, [Halstead metric](https://en.wikipedia.org/wiki/Halstead_complexity_measures) (number of operators in code) and some factors.

The exact calculation you can look up [here](https://docs.microsoft.com/en-us/archive/blogs/codeanalysis/maintainability-index-range-and-meaning).  
This number should be **between 20 and 100. The higher the better.**

If you have any question or you find any problem, create an issue on GitHub: [https://github.com/StefanMaron/vscode-allint](https://github.com/StefanMaron/vscode-allint)