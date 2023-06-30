---
title: 'Coding4Performance 2: Asynchronous development and background tasks'
date: Fri, 10 Jul 2020 07:52:14 +0000
draft: false
tags: ['Asynchronous', 'Business Central', 'Performance']
---

In this post I will explain the general concept of asynchronous development and background tasks.

So everyone knows how procedural development works. In Business Central it starts with a user which logs in to the web client and starts a user session. The first page which opens is most likely the role center page. Behind the scenes now every part runs some code and loads some data. Typically this happens from top to bottom. After a short moment every piece of code finished and the page is fully loaded and rendered. The user can not interact with the page until this is finished.

In most cases this is not a problem because the server is new or even in the cloud and scalable. Also the users desktop was recently changed so chrome has its 4GB of memory available. Altogether the page loads in less than one second.

But what if one or even every of this conditions are not given? Or the role center needs to display some statistics which need more time to generate?

In this case the user also needs to wait for everything to be finished, and this can take quite some time. If this happens every time the user hits the role center, it can become quite annoying and time consuming.

This is where background tasks have their benefits. Imagine that you can simply send the generation of statics to the background. The user will still have to wait the same time for the statics to show up, but the page will be loaded already and the user can interact with it and if the statistics are not needed it is possible to navigate to other pages and continue to work.

Background tasks
----------------

I created a figure to show the concept.  

![](https://stefanmaron.files.wordpress.com/2020/07/image-12.png)

Normally each user session runs in their own context and does one task after the other. But if you send one task to run in background, a new session is startet and runs parallel to the user session.

The user 1 has to wait only for task 1 and task 3 to complete. Task 2 will just be startet and then runs in background, in the same time as task 3 runs in the user session.

This concept applies to background tasks startet with [Start Session](https://docs.microsoft.com/en-us/dynamics-nav/startsession-function--sessions-) and to [Page Background Tasks](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-page-background-tasks).

Asyncronous development with a background queue
-----------------------------------------------

Again first the concept figure.

![](https://stefanmaron.files.wordpress.com/2020/07/image-11.png)

If you start a background task like explained before it will run directly and on the same server instance as the user session is started from. But sometimes you may want to run something in background but it also can run during night times?

Imagine that you have again the user session but instead of running the task 2 directly it is written to a queue for some background worker to pick this up and do your tasks.

This queue can have several worker which are just checking if there is a new task and then start doing this task. This is similar to the Job queue in BC but I am talking about the [Task Scheduler](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-task-scheduler).

The Page Background Tasks are documented quite well by Microsoft already I think. But on how to use Start Session and how to use the Task Scheduler I will write separate blog posts for detailed explanation.