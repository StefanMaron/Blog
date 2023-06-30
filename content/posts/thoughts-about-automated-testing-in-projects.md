---
title: 'Thoughts about automated testing in projects'
date: Mon, 01 Feb 2021 09:34:04 +0000
draft: false
tags: ['Allgemein']
---

I just finished a somewhat successful project with one of my customers, starting with BC from scratch only with some master data imported. For some more critical processes I wrote some basic test cases and automated them. Although this project did not fail and the customer can work with BC without problems now, I had a feeling of just being lucky.

I mean, I know what I am capable of and I was confident to do this project from the beginning. But I have the feeling that, with proper test, this whole project would have been on a totally higher level.

#### "... but in projects, automated test do not pay off!"

I don't remember where I got this from, but it is somehow burned in my head. That the customer does not pay the effort for writing these test. That the customer responsible of testing. Phrases like these.

So I asked you folks about this, what your opinion is:

![](https://stefanmaron.files.wordpress.com/2021/02/image.png)

And the result surprised me. I did expect that you would rather be on the "test are worth" side, but not that much. I mean, only one vote went for "not worth at all"!

#### So should we be automating tests in projects?

I think the main question we should be asking is "Does the customer want to have a tested app?"

![](https://stefanmaron.files.wordpress.com/2021/02/image-1.png)

I like the idea to think about test (in general) like an insurance or like the net of an circus acrobat. Most of the time you know what you are doing when you develop an app. If not you probably would not be working as a developer. But what happens if you have a bad day? Or simply do a mistake? We are only humans. Everyone makes mistakes. if you don't see the mistake before the code goes to production, it can have quite some impact.

#### "... but for this we do manual testing of the code"

This is what I hear quite often when discussing automated tests. Or that the customer needs to test the new version.

But honestly, do you test **everything!** again after one minor change is made? Every time? The whole app? Probably not. The problem is, one minor change on feature D can break feature A and also C although there were not touched for months!

#### Do we want to provide tested apps?

This is the main question we should be asking. And customer testing, or some basic manual testing of a recently made change or feature, is does not make an app "tested"!

And this is what my feeling in my last project was. It felt like we just delivered untested code. Of course we did quite a few full test runs to hit all features, but when doing bug fixes this is simply not possible and then untested code goes to production.

#### "The customer wants working code!"

![](https://stefanmaron.files.wordpress.com/2021/02/image-2.png)

So if we think about quality, test are a must. There is no question about whether or not to test. And then, automating these tests, saves time and money.

#### What does this mean for partners?

In a business central world where we have monthly upgrades, app dependencies and software as a service, our quality level got raised above our comfort zone. I like to say "**NAV <> BC"**. We can not compare today's projects to the "good old days" we did projects with NAV. We need to change the whole process of doing projects. Started with Presales, over how to invoice and also the quality we want to deliver. I do not have answers on how or by whom this gets payed. But in my opinion it is not possible to go on like we did.