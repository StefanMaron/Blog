---
title: 'Performance &amp; Variables exposed as field on a Page'
date: Tue, 02 Mar 2021 19:01:27 +0000
draft: false
tags: ['Business Central', 'Performance']
---

Today was again one of those days...

I just wanted to add a flow field to a table to look up some value, and display it on a list page. After some time I realized that this wont work. Im my case I needed to go three table relations deep to get out the value I needed. But just chaining two FlowFields would already be enough to see this mission failing.

But luckily we (or most of us :p) learned this lessen already in C/AL times: Just add a variable inDataSet and fill it with custom code. This you can easily display. The customer may not be able to filter or sort, but if this is not necessary, you are good to go.

And a solution could look like this if you are done:

![](https://stefanmaron.files.wordpress.com/2021/03/image.png)

I finished hacking this in my vs Code and tried it. Everything was displayed correctly. Now the fine tuning.

Requirement was, that this should be available for two or three out of the about 30 users. Means, field would not be visible by default, and everyone who want to see it can just add it with personalizing. Done. Easy.

But wait!
---------

Then it got me thinking. What am I doing here? The calculation of my values will happen even if the field is not visible. So the majority of users would generate load on the system and loading times for \*nothing\*.

I need to say at this point: If we are talking about some style expression or some other one-liner we would probably never get into any trouble. But in my scenario looking up this value at its price ;)

So what can I do? I went to docs and searched if there would be any possibility to know if this damn field is currently visible or not. Then I would be able to execute my code only, if the user changed this field to be visible. But you can probably already tell, that I had no luck.

I continued thinking about doing some kind of hack to achieve this. Maybe a custom visible variable and an action to toggle the field? But then I would need to save this setting for every user... But I dont want to generate even more customizations...

Long story short, I asked a colleague for his opinion. It was a 5 minutes call and my problem was solved:

![](https://stefanmaron.files.wordpress.com/2021/03/image-1.png)

You can skip the whole variable assignment if you need to evaluate it for every line anyways.

**This way, the function will actually only be called if the field is visible on the page.** I am not aware of any side effects of this solution. If you know any, feel free to leave a comment ;)

I thought I'd share this and hope it can save you the time I spend today searching for a solution.