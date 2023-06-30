---
title: 'VS Code extension: AL Lint'
date: Sat, 08 Aug 2020 13:34:19 +0000
draft: false
tags: ['AL Lint', 'ALLint', 'CleanCode', 'VSCode']
---

Maybe you have read this in twitter already: I took over the [AL Lint extension](https://marketplace.visualstudio.com/items?itemName=StefanMaron.allint) for VS Code from Marije Brummel. She searched quite some time already for someone and finally she found me :D

For now I did two things on this extension for now.

1.  I worked myself a little bit into extension development for VS Code and did a little bit of refactoring, updated some dependencies to new versions and removed checks which are now covered by the AL Code Cops.
2.  I already added a new check for function Line Numbers. By default you will get a warning for functions with more than 40 lines of code. Dont be afraid, you can always increase this number in your settings.json or even deactivate it by setting it to 0.

For the future I plan to cover code checking beyond the AL Code Cops. Meaning, checks by AL Lint will go for clean code, maybe performance issues and things like this. Things which will still let you run your code but could be done better ;)

Note that I did not take over the GitHub repository from Marije. So issues will not be transferred!

**Call for contributors!** Feel free to do pull requests and open issues. Not only for bugs but also feature request are welcome.

Link to VS Code Marketplace: [AL Lint](https://marketplace.visualstudio.com/items?itemName=StefanMaron.allint)  
Link to GitHub repository: [vscode-allint](https://github.com/StefanMaron/vscode-allint)