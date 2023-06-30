---
title: 'Coding4Performance 3: Start Session'
date: Sat, 11 Jul 2020 07:48:15 +0000
draft: false
tags: ['Business Central', 'BusinessCentral', 'Performance']
---

As promised, here the first (and easiest) way to run code in background. This blog will be a bit shorter, as [Start session](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-startsession-method) is quite straight forward. Note: If you did not read the previous blog about [Background tasks in general](https://stefanmaron.wordpress.com/2020/07/10/coding4performance-2-asynchronous-development-and-background-tasks/), maybe you should start there ;)

I created an example scenario for which a background task could be useful. Maybe you want your customers to be correctly set up before anyone is able to post any invoice or shipment for them.

Normaly you would go for the OnModify trigger and write some code which checks the customer data. If anything is not correct you set the customer to blocked = all otherwise you unblock the customer. Maybe you fill some info on what is not correct, and maybe some more things.

As you can imagine this can get quite much of checking and writing info in tables for the user to review and such. So every time a user changes something and triggers the OnModify() all of this code needs to run. If you have any routines which update a bunch of customers at once this even gains more impact.

If you already have the logic on how your customer is checked, its easy to let this run in background.

#### Step 1: Move your code to a separate Codeunit

Yes, this is correct. If you want to run things in background you need a Codeunit for each of them. This is because for Start session and other background code commands, you can only pass a Codeunit to define what should be run in background.

So I created a Codeunit to do some simple checks on a customer record:

![](https://stefanmaron.files.wordpress.com/2020/07/image-13.png)

For this kind of Codeunits waldo's Method-Codeunit-Pattern comes in handy. To use it you can install the [CRS VS Code extension](https://marketplace.visualstudio.com/items?itemName=waldo.crs-al-language-extension) and use the snippet "tcodeunittcodeunitMethodWithoutUIwaldo". Just the public procedure needs to be replaced with the OnRun trigger and you need to set the TableNo property.

EDIT: Here is the explanation of that pattern ;) [Method Codeunit Pattern on YouTube](https://youtu.be/j4WiWv1BGE4?t=3598)

Note that you can not have any GUI interactions in this code, as it runs in background. Details on this you can read in the [Docs article](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-startsession-method#remarks).

#### Step 2: Call the Codeunit with StartSession()

After you refactored your code to a separate Codeunit you just need to call it from the OnBeforeModify() trigger of the customer.

![](https://stefanmaron.files.wordpress.com/2020/07/image-14.png)

This way, only the start of the new session happens OnModify() and the user does not need to wait for the whole check logic to complete.

After your code is finished the background session closes automatically.

All of this code you can find on my [GitHub](https://github.com/StefanMaron/Coding4Performance)!