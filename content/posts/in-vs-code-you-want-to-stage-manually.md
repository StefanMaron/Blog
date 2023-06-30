---
title: 'In VS Code you want to git stage manually...'
date: Mon, 09 Nov 2020 15:34:55 +0000
draft: false
tags: ['Allgemein', 'development', 'git']
---

After a longer break with blogging, I am now back with a really short one. But I thought this would be worth sharing ;)

Thanks to [@waldo1001](https://twitter.com/waldo1001) and [@KarolakNatalie](https://twitter.com/KarolakNatalie) who opened my eyes on this one :)

You might know this little message, although you might have already forgotten that you got asked, when you fist started working with VS Code.

![](https://stefanmaron.files.wordpress.com/2020/11/image.png)

It seems like this can really save some time and work. But I just recently leaned this setting comes at a cost.

But what is even a stage? In my own words explained: You need to tell git which changes you want to commit. This enables you to select which changes you want to commit when you have multiple files edited. And without staging changes you can not commit.

In VS Code you can stage files one by one with the little plus sign:

![](https://stefanmaron.files.wordpress.com/2020/11/image-2.png)

All files with the plus on the header line:

![](https://stefanmaron.files.wordpress.com/2020/11/image-3.png)

You can also select multiple files with shift+click and then click stage on one of the selected files.

#### Rename Files in a git repository

If you did not try this before let me show you what happens when you rename a file in a git repository

![](https://stefanmaron.files.wordpress.com/2020/11/image-4.png)

U - untracked  
D - deleted

Git identifies files with their name. So if you rename a file the history get broken. Until now, I just lived with this fact. If you have the auto stage enabled you would need to manually rename all files with a separate git command.

Now the trick: If you stage these files manually with the click on "plus", git recognizes the rename automatically!

![](https://stefanmaron.files.wordpress.com/2020/11/image-5.png)

How cool is that?

But how to change this behavior that you wont get asked every time to enable automatic staging?

If you get asked again you can simply click never:

![](https://stefanmaron.files.wordpress.com/2020/11/image-6.png)

If you are more a friend of manual setting you need to set these two settings:

![](https://stefanmaron.files.wordpress.com/2020/11/image-7.png)

So I hope you can profit from this little tip as much as I do already ;)