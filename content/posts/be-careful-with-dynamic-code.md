---
title: 'Be careful with dynamic code'
date: Wed, 11 Aug 2021 07:09:13 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'BusinessCentral', 'CleanCode', 'Performance']
---

I believe there is a time in every AL developers live where he discovers the power of RecordRef and FieldRef. It is surely Incredible what you can achieve with these tools and how fast you can deliver a pretty good working piece of code.

At least this is the way I remember my first solutions I build when I first learned about RecordRefs. I realized, the more I think about it the more code could be written with a dynamic approach and I started to deliver my finished code quite a bit faster.

But...

![](https://stefanmaron.files.wordpress.com/2021/08/ae207372837cec0d56db1db481893176.jpg)

I mean, everyone keeps telling that you should be careful when using those because it can get slow. And I did not listen as good as I should have :D

Recently I got a task to analyze performance problems in a customer database and I decided to give the Performance Toolkit a try. I started with my test runs on a database without any custom app and then installed them again one by one. This was the result:

![](https://stefanmaron.files.wordpress.com/2021/08/image.png)

I believe the huge peak was due to caching which first needed to be build, but you can see that the runtime never got back to normal again. And we are not talking about 20% performance loss, more likely about 650%. The time needed to modify a sales header went from about 6 ms to 4500 ms. That is almost 5 seconds to wait on each modify of a sales header.

**What caused this?**

Well, I thought it would be a neat solution if I iterate over all table relations of the sales header and check in related tables if I need to load any information. The data itself was still designed dynamically so it could be (theoretical) added to any table.

Most of you are probably now thinking: "Well, if you do stuff like this, you need to expect things getting slow". But be honest, would you have expected things getting this slow?

At least I did not expect it getting that bad. But I was even more surprised that once I changed this function to only check load from a defined set of related tables, I was not able to measure any difference in performance anymore, compared to vanilla BC.

**My conclusion**

I realized that building this kind of dynamic solution can lead to huge losses of performance. Since we are now living in a world where cloud solutions and web clients dominate and all kinds of integrations to 3rd party software are build, performance is needed more than ever.

By now I started to rebuild this whole solution based on interfaces. This makes my code static. It only works for entities I wrote the code for, but due to the interface implementation, it is still extendable.

Interesting is, that this rebuild did not only improve performance by \*a lot\*. It also increased the usability since I also changed cryptic actions and fields. Before there needed to go along with the dynamic solution in the background, now they show exactly and only those options available.

Another benefit is, testability. You simply write your tests for all those interface implementations and you have already quite some test coverage. I mean, you could also wirte those test on the dynamic approach, but I believe its easier to get your head around what tests are needed if the code to test is static.

Last but not least, its much better to read now. Not only for others, but for me too :D