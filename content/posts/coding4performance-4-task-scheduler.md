---
title: 'Coding4Performance 4: Task Scheduler'
date: Wed, 15 Jul 2020 09:13:05 +0000
draft: false
tags: ['background', 'Business Central', 'BusinessCentral', 'Performance']
---

In my last post about [Start Session](https://stefanmaron.wordpress.com/2020/07/11/coding4performance-3-start-session/) I explained how you can easily run a Codeunit in background and relieve the user session. The downside on this method is, that your background task still runs on the same server instance like the user session does. If you have only a few users and only one server instance you are good to go. But if not, then the [Task Scheduler](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-task-scheduler) could be of interest for you!

The key concept of the task scheduler is a queue table. If you call the CreateTask method from the user session, a new record is written into this queue table. If the task is marked as ready, a new background session is started automatically and runs your specified Codeunit.

The reason why this is more flexible on which server instance to use, is the service level option to specify whether or not this instance should run the task scheduler.

![](https://stefanmaron.files.wordpress.com/2020/07/image-15.png)

If you work with docker then you need to add the parameter -enableTaskScheduler to your New-BcContainer command:

![](https://stefanmaron.files.wordpress.com/2020/07/image-16.png)

So what you want is typically one (or more, depends on number of users) instance for the user sessions where the task scheduler is disabled. And at least one (or, again, more depending of number of task you want to run in background) instance for running the task scheduler, obviously with the task scheduler being enabled. The server instance(s) for the task scheduler can also be located on a different server machine for optimal load distribution.

There is one more major advantage on the task scheduler combined with server instance separation. You can always add more services with zero configuration overhead because if one instance has its maximum concurrent tasks running the next instance will start working on the next tasks.

If you did the example of my previous blog about [Start Session](https://stefanmaron.wordpress.com/2020/07/11/coding4performance-3-start-session/), this is all you need to change to switch for using the task scheduler:

![](https://stefanmaron.files.wordpress.com/2020/07/image-17.png)

For testing the code you change the third parameter "IsReady" to false and open table number 2000000175 [http://<ServerName>/<InstanceName>/?table=2000000175](http://bc16perftest/BC/?table=2000000175) you can see the task you just created.

![](https://stefanmaron.files.wordpress.com/2020/07/image-18.png)

As you can see in the picture in the column "NotBefore" you can even schedule a task to run at night times for example, to further reduce load during the normal business hours.

I hope I could give you an introduction about the task scheduler that will get you started running workload in background and give your end users a nice user experience ;)

Again you can find the code in my screenshots on my [GitHub](https://github.com/StefanMaron/Coding4Performance)!