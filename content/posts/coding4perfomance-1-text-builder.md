---
title: 'Coding4Performance 1: Text Builder'
date: Mon, 06 Jul 2020 08:04:47 +0000
draft: false
tags: ['Business Central', 'BusinessCentral', 'Performance']
---

As NAV and Business Central evolves user tasks become more complex and BC becomes more powerful to solve this tasks. But this happens often with cost in performance. Even Microsoft published a (very good) [article](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/performance/performance-overview) about how to improve performance in BC.

I do mainly concentrate on the developer aspect of this article and in this post especially on the [TextBuilder Data Type](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/textbuilder/textbuilder-data-type).

So it is described that working with this Datatype instead of gluing strings with += together is much more efficient. But how much is much more?

To prove this huge performance boost I created a small test codeunit and run some loops.

![](https://stefanmaron.files.wordpress.com/2020/07/image-4.png)

The first loop adds 100.000 times a 'a' into a text variable. The second one uses the TextBuilder variable to do the same. Here is the result:

![](https://stefanmaron.files.wordpress.com/2020/07/image-6.png)

I repeated the test with 10 million times 'a'. I canceled the test with the text variable after more than 4 hours. Interesting here is, that it takes longer than ~ 500 seconds although the test with 10 million loops has exactly 100 times more loops. Take a closer look at the article about [TextBuilder](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/textbuilder/textbuilder-data-type#remarks) in the MS Docs. There is explained that the normal text variable needs to reallocate memory for the whole string **each time you add a string to it**. This means that the 10 million a's take exponentially more time to process than the 100.000 a's.

![](https://stefanmaron.files.wordpress.com/2020/07/image-7.png)

But with the TextBuilder we even have a few more functions that come in handy. But how do they perform? (Note: There are still more functions for you to discover by yourself!)

**AppendLine()** is exactly as fast as adding only text!

![](https://stefanmaron.files.wordpress.com/2020/07/image-8.png)

**Replace()**: Yes that is right! We do have a replace which can replace without any length restriction like ConvertStr() has. To test this I added 10 million times 'abc' and then replaced 'bc' with 'a':

![](https://stefanmaron.files.wordpress.com/2020/07/image-9.png)

Still only 6 seconds!

![](https://stefanmaron.files.wordpress.com/2020/07/image-10.png)

In conclusion I think that the new TextBuilder can really speed things up!

But: My examples and test are quite provoking the bad performance of normal text variables. That is because in normal examples from daily work, you would probably not see any difference.

Anyway I think that I will use the TextBuilder in my daily work more often, just for the handy functions it has.