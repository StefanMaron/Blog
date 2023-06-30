---
title: 'Coding4Performance 5: FindSet vs FindFirst'
date: Thu, 23 Jul 2020 06:26:19 +0000
draft: false
tags: ['Business Central', 'BusinessCentral', 'Performance']
---

Today in coding for performance, we talk a bit about FindSet and FindFirst. I actually had plans to make this one the first post in this series. But it turned out that the differences between this two commands are not as obvious as I first thought.

Let me first place a huge **disclaimer** here: Everything I test and explain here is done with Business Central version 16. It might be that earlier versions of BC and NAV behaved differently.

#### How I thought they behave

I am doing NAV and BC now for around 5 years. And I learned that FindFirst is for when I need one record and I do not know the primary key value of this record.

```
Customer.SetFilter(Name,'%1\*','Candoxy');
if Customer.FindFirst then
  //DoSomethingWithCustomer
```

Obviously if I need to process all records there might be I need to use FindSet.

```
Customer.SetFilter(Name,'%1\*','Candoxy');
if Customer.FindSet then
  repeat
    //DoSomethingWithCustomer
  until Customer.Next() = 0;
```

Well, I assumed that they are optimized for what they do and only for what they do. So when I would do something like this it would be incredibly slow. As the SQL Server would read the result set somehow line by line and not all together.

```
Customer.SetFilter(Name,'%1\*','Candoxy');
if Customer.FindFirst then
  repeat
    //DoSomethingWithCustomer
  until Customer.Next() = 0;
```

Also this would be super slow with many records as BC requests all records with this filter from the database only to use the first one.

```
Customer.SetFilter(Name,'%1\*','Candoxy');
if Customer.FindSet then
  //DoSomethingWithCustomer
```

Of course everything gains more impact with more records, but I always assume that after a few years of working with BC the database grows and things become slower.

#### How they actually behave

My first attempt to prove my assumptions was to measure the difference in performance of FindSet and FindFirst. So I set up some disciplines and tested both commands how they performe (for details you can see what I did in my [GitHub](https://github.com/StefanMaron/Coding4Performance) ;) ):

![](https://stefanmaron.files.wordpress.com/2020/07/image-19.png)

I did not expect the result at all. They performe nearly identical.

But on SQL Server level there need to be a difference! So I checked the SQL queries with the debugger.

This what FindSet looks like:

```
SELECT "50000"."timestamp","50000"."Entry No\_","50000"."Text Field 1","50000"."Text Field 2","50000"."Text Field 3","50000"."Text Field 4","50000"."$systemId" 
FROM "CRONUS".dbo."CRONUS AG$Large Table$514935ce-8823-4405-92ff-ea2733089207" "50000"  WITH(READUNCOMMITTED)  
ORDER BY "Entry No\_" ASC OPTION(OPTIMIZE FOR UNKNOWN, FAST 50)
```

And this is the FindFirst query:

```
SELECT  TOP (1) "50000"."timestamp","50000"."Entry No\_","50000"."Text Field 1","50000"."Text Field 2","50000"."Text Field 3","50000"."Text Field 4","50000"."$systemId" 
FROM "CRONUS".dbo."CRONUS AG$Large Table$514935ce-8823-4405-92ff-ea2733089207" "50000"  WITH(READUNCOMMITTED)  
ORDER BY "Text Field 1" ASC,"Entry No\_" ASC OPTION(OPTIMIZE FOR UNKNOWN)
```

Aha! In the SQL query for FindFirst there is a TOP (1) and with FindSet there is not. The TOP(1) means that only one record will be received from the database. As the query for FindSet does not have this, it needs to receive all records at once.

But why in BC both are so damn fast?

Today I discovered that you have [insight](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/sessioninformation/sessioninformation-data-type) in the database statistics from test functions. So I did further digging. How many rows are actually received from the database.

Note: The error here is no real error, it is just to display the numbers in the test results ;)

```
SelectLatestVersion();
OffSetSqlStatementsExecuted := SessionInformation.SqlStatementsExecuted;
OffSetSqlRowsRead := SessionInformation.SqlRowsRead;

LargeTable.FindSet();

Error(
  'Statements executed: %1\\Rows read: %2',
  SessionInformation.SqlStatementsExecuted - OffSetSqlStatementsExecuted,
  SessionInformation.SqlRowsRead - OffSetSqlRowsRead
);
```

![](https://stefanmaron.files.wordpress.com/2020/07/image-21.png)

**First** thing to notice is: FindSet without a Next() does really only read one single row! I do not know the SQL Server details on this one and how its possible to achieve something like this, but it seems to work and its fast.

**Second** thing to notice: A FindFirst with repeat next until does need more queries on the database than a FindSet. So there might not be a huge difference in performance at my scale of testing, but at least there is a minor difference.

#### Conclusion

Even though FindFirst and FindSet might performquite equally in this test cases, in my opinion this should not by a reason to mix them up. I will go on as I did before, using only FindSet if I need to loop and if I only need the first record I will use FindFirst.

Again: Go to my [GitHub](https://github.com/StefanMaron/Coding4Performance) and check it for yourself ;)