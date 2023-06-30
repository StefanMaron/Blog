---
title: 'MSDyn365BC.Code.History'
date: Wed, 13 Jan 2021 16:28:03 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'github', 'history', 'versions']
---

Did you ever wonder what was changed in a cumulative update in Business Central? Sure, you can read the update notes from Microsoft and read the list of bug fixes they made. But I mean like, really know what was changed. Like, which line was changed on the customer table from between 2 versions?

Well, I did. For my own code I can always go to the repository and see all the code history. I can see every change that was ever made.

Microsoft does have a repository on GitHub as well and I am sure you know it: [AlAppExtensions](https://github.com/microsoft/ALAppExtensions)

While this is the place to create Issues regarding anything related to Business Central code written my Microsoft, this is not what I have in mind. You can not see the exact code base that is running in your Business Central instance. And you do not have a clear version history.

#### So I created my own...

... and I will share it with you! [StefanMaron/MSDyn365BC.Code.History (github.com)](https://github.com/StefanMaron/MSDyn365BC.Code.History)

I wrote a PowerShell script to download, extract and commit all OnPrem versions, for every country.

This is the folder structure:

![](https://stefanmaron.files.wordpress.com/2021/01/image-1.png)

I created a branch for every country and major version (for example "de-17"). This means that after 16.5 the next version 17.0. So you can compare 17.0 to 16.5. But in the 16 branch the next version after 16.5 would be 16.6 and so on. Like this you can compare every version by the logical order.

I will try to update this repository always as soon as Microsoft releases new versions for Business Central ;)

#### How to use it?

For a quick search you can use the "blame" function directly in GitHub:

You "Go to file":

![](https://stefanmaron.files.wordpress.com/2021/01/image-2.png)

Then you can just search though all the files (all objects):

![](https://stefanmaron.files.wordpress.com/2021/01/image-3.png)

When you opened the file you want to check, just activate the "blame" view on the right side:

![](https://stefanmaron.files.wordpress.com/2021/01/image-4.png)

Now you can see, for every line, when it was changed last:

![](https://stefanmaron.files.wordpress.com/2021/01/image-5.png)

By a click on that version you can open up all changes that where made with this CU and even open up the repository in this particular version to look at different files.

#### Disclaimer!

All code uploaded is obviously not mine. All code is owned by Microsoft. You can not do any pull request on this repository.

I hope my little project can help you as much as it helped me already!

Have fun and please share this with others who also can make use of this!