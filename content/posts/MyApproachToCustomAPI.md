---
title: "My approach to custom APIs"
date: 2023-07-04T08:05:27+02:00
draft: false
---

Since I work together with our colleagues from the PowerPlatform team more frequently, one of my most regular tasks is, to create a new custom API.
The default APIs from Business central are cool, but if you really want to achieve something, you might get to their limits real fast.

So I have been exposing tables and writing APIs quite a lot recently, and my approach to this has changed a bit over time.

## API for Readonly purposes

Probably the biggest requirement is, just to be able to access data. Maybe for PowerBI or just to get hold of some information in BC which is not yet exposed.
Typically, I create those APIs as API-Queries. Just because there is no faster data access in BC than queries. And you can do fancy stuff like grouping or calculating sums right away.

**Really important for this: get the requirements right!**
If you are a BC Developer and find yourself in this task, make sure to ask enough questions.
Its not that much work to create two or three more APIs. But if you do so, and you deliver the data maybe prefiltered or pregrouped, it can enhance performance quite a bit.
The reason is, that the data operation will be handed off to the SQL Server. Less data needs to be queried, and less data will need to be sent over to the external system.
Also, with all respect to PowerBI, SQL Server is faster at filtering and grouping!

**And for all the Power Folks out there: Please also be aware of this fact.** If you need grouping or filtering, the API is custom for your purpose. So why not making it exactly for what you need. This will save you time, and it will make everything run much more smoothly.

## APIs for writing to BC

This one is a bit more complex and probably also more controversial.

And there are probably at lease two scenarios I can see of right now.

### 1. Write back data which will get processed further in BC

In this case, the API is meant to receive data and store it in BC. Possibly the table is also custom.
Meaning: there is no or very minimal logic attached to this process. This could be some kind of log thats written, or just Master data information thats going to be validated by a user at some point.

In this case, I would go with a API Page most of the time, and include either just all fields from the table, or just fields needed.
As I said, very minimal logic is executed in BC. Its just about getting the data into the system.

### 2. Write data to BC with more logic

Now, since there is one case with less logic, there need to be one with more logic, right?   
This case is why I started this post, and what I wanted to share.

If you have created some custom APIs before you might already know the struggle. 
Number Series, field validation, insert logic inside management codeunits, after insert release logic, and probably more.

Those are just a few examples for logic that needs to get executed when data is written to BC. And it needs to be the right order.
For me its quite difficult to achieve this with just an API Page. It took me a huge number of test iterations in past to get it to work correctly.
And automated tests are either really difficult to get working, or near impossible.

For those reasons, I started to take a different approach: **Bound Actions**
If you dont know them yet, here are some links to get you started:
There are a caveats, you need to be aware of, but those links should cover them. 

[Creating and Interacting with an OData V4 Bound Action](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-creating-and-interacting-with-odatav4-bound-action)  
[Dynamics 365 Business Central: using OData V4 Bound Actions](https://demiliani.com/2019/06/12/dynamics-365-business-central-using-odata-v4-bound-actions/)

So what I now try to do is, to get the business requirements straight and understand what the requirements is, the API is needed for. 
In my most recent example this was to insert a new price list line for a vendor item combination. 
And while this might sound easy at first, and I thought so as well, there is a number of steps required.

1. Check if all the parameters are valid.
    1. Does the Vendor exits?
    2. Does the Item exits?
    3. Are Start and End Date valid? We dont what to support overlapping prices for this feature.
    4. Is the Price valid?
2. Check if the vendor already has a price list thats used to store the external prices? If yes, return that price list, otherwise a new one needs to get created
3. Insert the new price list line. And if you ever created one manually, you know, it also need to get validated. This means, a codeunit needs to get executed.

Now, why all the checks? The base code will scream, if something is wrong right?

Well, even for BC users, not all the error messages are always so clear to understand. So I wanted to make sure to give proper error message that I can control.
And I can verify the input parameters at the very beginning. So the database will not have to insert or read data, and possible roll back the data if an error occurs.
Again, this will help to have a nice and fast API.

Next advantage: I can actually test this. I can put the code in a codeunit thats called from the API Page, and in my tests, I can just call the codeunit directly.
I do not need to worry about the API in my tests at all. This will make my tests less complex and faster. 
And if you follow any kind of pattern for this, maybe the [MethodPattern](https://alguidelines.dev/docs/patterns/generic-method-pattern/) or the, how I call it, [FactoryPattern](https://github.com/vjekob/bctechdays2023). You can apply those with ease.

Alright, I think thats all I wanted to write off my heart for now. Thanks for reading :)