---
title: 'Condition basics in AL'
date: Tue, 04 Aug 2020 12:58:24 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'BusinessCentral', 'CleanCode', 'Guidelines']
---

Recently I posted a "[Did you know that ...](https://twitter.com/StefanMaron/status/1289063800231153664?s=20)" post on Twitter showing an alternative way to write an if-condition. Today I thought: Hey, I might have some more examples for different ways to write conditions and here we are ;)

First start with the most simple if statement there is:

![](https://stefanmaron.files.wordpress.com/2020/08/image.png)

It just checks if the text variable is empty and if this is the case, some code is executed. Note that in AL the parentheses are not needed if you have only one condition or if you compare booleans.

This was easy. Now an example about how to check if two text variables are empty:

![](https://stefanmaron.files.wordpress.com/2020/08/image-1.png)

In this example parentheses are mandatory because in AL the "and" would try to evaluate this:

```
'' and MyTextVar2
```

Okay so far so simple. If you need to evaluate more than two conditions and maybe even nest conditions this can get messy.

![](https://stefanmaron.files.wordpress.com/2020/08/image-7.png)

I think you get the point.  
If this happens I tend to write the conditions this way:

![](https://stefanmaron.files.wordpress.com/2020/08/image-8.png)

It looks strange at the beginning but on the second glance it is more clear to read. (At least in my opinion ;-) )

This is even easier to do for an "or" statement:

![](https://stefanmaron.files.wordpress.com/2020/08/image-6.png)

The IN statement checks if the value before IN is at least once within the list of values which follows.

Now, how about this example:

![](https://stefanmaron.files.wordpress.com/2020/08/image-9.png)

You can shorten this up with a simple case true of:

![](https://stefanmaron.files.wordpress.com/2020/08/image-10.png)

If nothing helps and your condition is not clear to understand, put it into a function with a name explaining what your condition is:

![](https://stefanmaron.files.wordpress.com/2020/08/image-11.png)

And don't be afraid of long function names. Best is, if you can read the if statement like plain english.

And of course: Go to my [GitHub](https://github.com/StefanMaron/Coding4Performance) and check it for yourself ;)