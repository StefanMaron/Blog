---
title: "Indirect Permissions in Business Central"
date: 2024-10-06T20:28:30+02:00
draft: false
---

# Indirect Permissions in Business Central

Recently I created a new Rule in the BC Linter Cop to inform about missing `Permission` to do data Access:  
https://github.com/StefanMaron/BusinessCentral.LinterCop/wiki/LC0068

This resulted in a number of discussions about when to set the `Permissions` property, and if it makes sense at all.

https://github.com/StefanMaron/BusinessCentral.LinterCop/pull/768  
https://github.com/StefanMaron/BusinessCentral.LinterCop/issues/725  
https://github.com/StefanMaron/BusinessCentral.LinterCop/issues/780

... and some more, also on other platforms.

So I want to use this Blog post to try to really explain my reasoning behind the rule and why I think that it does make sense exaclty as it is.

## Background

It all started when I was working on a customer project. I was working on some custom E-Mail functionality and wanted to link the Sent Mails Id in my custom table:

![SentMailCode](/images/SentMailCode.png)

And I am sure every developer has seen the error message `You do not have the following permissions on TableData .... : Read.`

But with Sent Emails it was a different one, it said `...: Read`!
I had never seen that before, and I was a bit confused at first, so I checked my Effective Permissions.

![SentEmailsIndirectPermissions](/images/SentEmailsIndirectPermissions.png)

As you can see this table has indeed indirect Read Permissions, although I have the `SUPER` Permission Set.

And to give you an overview of all Tables that would fall under this category in production environment right now, here is the total list of all **250** tables having at leas one of the `RIMD` set to indirect:

<details>
<summary>Indirect Permissions</summary>

| Object Type | Object Name | Read Permission | Insert Permission | Modify Permission | Delete Permission |
|-------------|-------------|-----------------|-------------------|-------------------|-------------------|
|Table Data|G/L Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Cust. Ledger Entry|Yes|Indirect|Yes|Indirect|
|Table Data|Vendor Ledger Entry|Yes|Indirect|Yes|Indirect|
|Table Data|Item Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|G/L Register|Yes|Indirect|Indirect|Indirect|
|Table Data|Item Register|Yes|Indirect|Indirect|Indirect|
|Table Data|Batch Processing Parameter|Yes|Indirect|Indirect|Indirect|
|Table Data|Batch Processing Session Map|Yes|Indirect|Indirect|Indirect|
|Table Data|Exch. Rate Adjmt. Reg.|Yes|Indirect|Indirect|Indirect|
|Table Data|Date Compr. Register|Yes|Indirect|Indirect|Indirect|
|Table Data|Sales Shipment Header|Yes|Indirect|Indirect|Yes|
|Table Data|Sales Shipment Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Sales Invoice Header|Yes|Indirect|Indirect|Yes|
|Table Data|Sales Invoice Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Sales Cr.Memo Header|Yes|Indirect|Indirect|Yes|
|Table Data|Sales Cr.Memo Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Purch. Rcpt. Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Purch. Inv. Header|Yes|Indirect|Indirect|Yes|
|Table Data|Purch. Inv. Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Purch. Cr. Memo Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Job Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Exch. Rate Adjmt. Ledg. Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Res. Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Job Register|Yes|Indirect|Indirect|Indirect|
|Table Data|G/L Entry - VAT Entry Link|Yes|Indirect|Indirect|Indirect|
|Table Data|VAT Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Bank Account Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Bank Account Statement|Yes|Indirect|Indirect|Yes|
|Table Data|Bank Account Statement Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Phys. Inventory Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Issued Reminder Header|Yes|Indirect|Indirect|Yes|
|Table Data|Issued Reminder Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Reminder/Fin. Charge Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Issued Fin. Charge Memo Header|Yes|Indirect|Indirect|Yes|
|Table Data|Issued Fin. Charge Memo Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Item Application Entry|Yes|Yes|Indirect|Indirect|
|Table Data|Detailed Cust. Ledg. Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Detailed Vendor Ledg. Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Change Log Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Approval Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Posted Approval Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Posted Approval Comment Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Overdue Approval Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflow Webhook Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflow Webhook Notification|Yes|Indirect|Indirect|Indirect|
|Table Data|Dimension Set Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Dimension Set Tree Node|Yes|Indirect|Indirect|Indirect|
|Table Data|VAT Rate Change Log Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Standard Address|Yes|Indirect|Indirect|Indirect|
|Table Data|VAT Report Archive|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflows Entries Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Cash Flow Azure AI Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Job WIP G/L Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Job Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Job WIP Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Job Difference Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Line Fee Note on Report Hist.|Yes|Indirect|Indirect|Indirect|
|Table Data|Payment Reporting Argument|Yes|Indirect|Indirect|Indirect|
|Table Data|Cost Budget Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Payment Export Data|Yes|Indirect|Indirect|Indirect|
|Table Data|Field Monitoring Setup|Yes|Indirect|Yes|Indirect|
|Table Data|Net Promoter Score Setup|Indirect|Indirect|Indirect|Indirect|
|Table Data|Net Promoter Score|Indirect|Indirect|Indirect|Indirect|
|Table Data|Product Video Buffer|Indirect| | | |
|Table Data|Workflow - Record Change|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflow Record Change Archive|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflow Step Instance Archive|Yes|Indirect|Indirect|Indirect|
|Table Data|Workflow Step Argument Archive|Yes|Indirect|Indirect|Indirect|
|Table Data|Flow Service Configuration|Yes|Indirect|Indirect|Indirect|
|Table Data|Office Admin. Credentials|Yes|Indirect|Indirect|Indirect|
|Table Data|Option Lookup Buffer|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Logging Setup|Indirect|Indirect|Indirect|Indirect|
|Table Data|Fields Sync Status|Indirect|Indirect|Indirect|Indirect|
|Table Data|Cancelled Document|Yes|Indirect|Indirect|Indirect|
|Table Data|Guided Experience Item|Yes|Indirect|Indirect|Indirect|
|Table Data|User Checklist Status|Yes|Indirect|Indirect| |
|Table Data|Checklist Item Buffer|Indirect| | | |
|Table Data|Checklist Setup|Yes|Yes|Yes|Indirect|
|Table Data|Spotlight Tour Text|Indirect|Indirect|Indirect|Indirect|
|Table Data|Primary Guided Experience Item|Indirect|Indirect|Indirect|Indirect|
|Table Data|Azure AI Usage|Yes|Indirect|Indirect|Indirect|
|Table Data|Image Analysis Scenario|Yes|Indirect|Indirect|Indirect|
|Table Data|Sales Document Icon|Yes|Indirect|Indirect|Indirect|
|Table Data|Calendar Event|Yes|Indirect|Indirect|Indirect|
|Table Data|Calendar Event User Config.|Yes|Indirect|Indirect|Indirect|
|Table Data|Extension Pending Setup|Indirect|Indirect|Indirect|Indirect|
|Table Data|Feature Data Update Status|Yes|Indirect|Indirect|Indirect|
|Table Data|Translation|Indirect|Indirect|Indirect|Indirect|
|Table Data|Retention Policy Allowed Table|Indirect|Indirect|Indirect|Indirect|
|Table Data|Retention Policy Log Entry|Indirect|Indirect|Indirect|Indirect|
|Table Data|Persistent Blob|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email - Outlook Account|Indirect|Indirect|Indirect|Indirect|
|Table Data|Recurrence Schedule|Indirect|Indirect|Indirect|Indirect|
|Table Data|Logged Segment|Yes|Yes|Yes|Indirect|
|Table Data|RM Matrix Management|Yes| | |Indirect|
|Table Data|Employee Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Detailed Employee Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Production Order|Yes| |Indirect| |
|Table Data|Prod. Order Line|Yes| |Indirect| |
|Table Data|Prod. Order Component|Yes| |Indirect| |
|Table Data|Prod. Order Routing Line|Yes| |Indirect| |
|Table Data|Prod. Order Capacity Need|Yes| |Indirect| |
|Table Data|Prod. Order Routing Tool|Yes| |Indirect| |
|Table Data|Prod. Order Routing Personnel|Yes| |Indirect| |
|Table Data|Prod. Order Rtng Qlty Meas.|Yes| |Indirect| |
|Table Data|API Extension Upload|Indirect|Indirect|Indirect|Indirect|
|Table Data|Onboarding Signal|Indirect|Indirect|Indirect|Indirect|
|Table Data|FA Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|FA Register|Yes|Indirect|Indirect|Indirect|
|Table Data|Maintenance Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Ins. Coverage Ledger Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Insurance Register|Yes|Indirect|Indirect|Indirect|
|Table Data|Registered Whse. Activity Hdr.|Yes|Indirect|Indirect|Yes|
|Table Data|Registered Whse. Activity Line|Yes|Indirect|Indirect|Yes|
|Table Data|Value Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Rounding Residual Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Post Value Entry to G/L|Yes|Yes|Indirect|Indirect|
|Table Data|Capacity Ledger Entry|Yes|Indirect|Indirect| |
|Table Data|Invt. Receipt Header|Yes|Indirect|Indirect|Indirect|
|Table Data|Invt. Receipt Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Invt. Shipment Header|Yes|Indirect|Indirect|Indirect|
|Table Data|Invt. Shipment Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Inventory Adjustment Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Inventory Adjmt. Entry (Order)|Yes|Indirect|Indirect|Indirect|
|Table Data|Service Header|Yes| |Indirect| |
|Table Data|Service Item Line|Yes| |Indirect| |
|Table Data|Service Line|Yes| |Indirect| |
|Table Data|Service Ledger Entry|Yes| |Indirect| |
|Table Data|Service Shipment Buffer|Yes|Indirect|Indirect|Yes|
|Table Data|Service Contract Line|Yes| |Indirect| |
|Table Data|Service Contract Header|Yes| |Indirect| |
|Table Data|Filed Service Contract Header|Yes| |Indirect| |
|Table Data|Service Invoice Line|Yes| |Indirect| |
|Table Data|Item Tracing Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Item Tracing History Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Record Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Return Shipment Header|Yes|Indirect|Indirect|Indirect|
|Table Data|Return Shipment Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Return Receipt Header|Yes|Indirect|Indirect|Yes|
|Table Data|Return Receipt Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Warehouse Entry|Yes|Indirect|Indirect|Indirect|
|Table Data|Registered Invt. Movement Hdr.|Yes|Indirect|Indirect|Yes|
|Table Data|Registered Invt. Movement Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Copilot Settings|Indirect|Indirect|Indirect|Indirect|
|Table Data|Record Set Definition|Yes|Indirect|Indirect|Indirect|
|Table Data|Record Set Tree|Yes|Indirect|Indirect|Indirect|
|Table Data|Record Set Buffer|Yes|Indirect|Indirect|Indirect|
|Table Data|Table Information Cache|Indirect|Indirect|Indirect|Indirect|
|Table Data|Company Size Cache|Indirect|Indirect|Indirect|Indirect|
|Table Data|Feature Uptake|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Connector Logo|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Outbox|Indirect|Indirect|Indirect|Indirect|
|Table Data|Sent Email|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Message|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Error|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Recipient|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Message Attachment|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Scenario|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Related Record|Indirect|Indirect| |Indirect|
|Table Data|Email Scenario Attachments|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Rate Limit|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email Attachments|Indirect|Indirect|Indirect|Indirect|
|Table Data|Email View Policy|Yes|Yes|Yes|Indirect|
|Table Data|Plan|Indirect|Indirect|Indirect|Indirect|
|Table Data|User Plan|Indirect|Indirect|Indirect|Indirect|
|Table Data|User Login|Indirect|Indirect|Indirect| |
|Table Data|User Environment Login|Indirect|Indirect| | |
|Table Data|Plan Configuration|Indirect|Indirect|Indirect|Indirect|
|Table Data|Custom Permission Set In Plan|Indirect|Indirect|Indirect|Indirect|
|Table Data|Default Permission Set In Plan|Indirect|Indirect|Indirect|Indirect|
|Table Data|Security Group|Indirect|Indirect|Indirect|Indirect|
|Table Data|Custom User Group In Plan|Indirect|Indirect|Indirect|Indirect|
|Table Data|Support Contact Information|Yes|Indirect|Indirect|Indirect|
|Table Data|Application User Settings|Indirect|Indirect|Indirect| |
|Table Data|Document Service Cache|Yes|Indirect|Indirect|Indirect|
|Table Data|Permission Set Link|Indirect|Indirect|Indirect|Indirect|
|Table Data|Word Templates Table|Indirect|Indirect|Indirect|Indirect|
|Table Data|Word Template Field|Indirect|Indirect|Indirect|Indirect|
|Table Data|Word Templates Related Table|Indirect|Indirect|Indirect|Indirect|
|Table Data|Upgrade Tag Backup|Indirect|Indirect|Indirect|Indirect|
|Table Data|Upgrade Tags|Indirect|Indirect|Indirect|Indirect|
|Table Data|Production BOM Line|Yes| |Indirect| |
|Table Data|Sales Planning Line|Yes|Indirect|Indirect|Indirect|
|Table Data|Object|Yes|Indirect|Indirect|Indirect|
|Table Data|Permission Set|Yes|Indirect|Indirect|Indirect|
|Table Data|Permission|Yes|Indirect|Indirect|Indirect|
|Table Data|Date|Yes|Indirect|Indirect|Indirect|
|Table Data|Session|Yes|Indirect|Indirect|Indirect|
|Table Data|Drive|Yes|Indirect|Indirect|Indirect|
|Table Data|File|Yes|Indirect|Indirect|Indirect|
|Table Data|Integer|Yes|Indirect|Indirect|Indirect|
|Table Data|Table Information|Yes|Indirect|Indirect|Indirect|
|Table Data|System Object|Yes|Indirect|Indirect|Indirect|
|Table Data|AllObj|Yes|Indirect|Indirect|Indirect|
|Table Data|License Information|Yes|Indirect|Indirect|Indirect|
|Table Data|Field|Yes|Indirect|Indirect|Indirect|
|Table Data|License Permission|Yes|Indirect|Indirect|Indirect|
|Table Data|Permission Range|Yes|Indirect|Indirect|Indirect|
|Table Data|Windows Language|Yes|Indirect|Indirect|Indirect|
|Table Data|Code Coverage|Yes|Indirect|Indirect|Indirect|
|Table Data|SID - Account ID|Yes|Indirect|Indirect|Indirect|
|Table Data|AllObjWithCaption|Yes|Indirect|Indirect|Indirect|
|Table Data|Key|Yes|Indirect|Indirect|Indirect|
|Table Data|Add-in|Yes|Indirect|Indirect|Indirect|
|Table Data|Object Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|Chart|Yes|Indirect|Indirect|Indirect|
|Table Data|Upgrade Blob Storage|Yes|Indirect|Indirect|Indirect|
|Table Data|Report Layout|Yes|Indirect|Indirect|Indirect|
|Table Data|Active Session|Yes|Indirect|Indirect|Indirect|
|Table Data|Session Event|Yes|Indirect|Indirect|Indirect|
|Table Data|Server Instance|Yes|Indirect|Indirect|Indirect|
|Table Data|Document Service|Yes|Indirect|Indirect|Indirect|
|Table Data|Document Service Scenario|Yes|Indirect|Indirect|Indirect|
|Table Data|User Property|Yes|Indirect|Indirect|Indirect|
|Table Data|Device|Yes|Indirect|Indirect|Indirect|
|Table Data|Table Synch. Setup|Yes|Indirect|Indirect|Indirect|
|Table Data|Table Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|CodeUnit Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|Page Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|Report Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|Event Subscription|Yes|Indirect|Indirect|Indirect|
|Table Data|Intelligent Cloud|Yes|Indirect|Indirect|Indirect|
|Table Data|NAV App Data Archive|Yes|Indirect|Indirect|Indirect|
|Table Data|NAV App Installed App|Yes|Indirect|Indirect|Indirect|
|Table Data|NAV App Capabilities|Yes|Indirect|Indirect|Indirect|
|Table Data|NAV App Object Prerequisites|Yes|Indirect|Indirect|Indirect|
|Table Data|Time Zone|Yes|Indirect|Indirect|Indirect|
|Table Data|Aggregate Permission Set|Yes|Indirect|Indirect|Indirect|
|Table Data|NAV App Tenant Add-In|Yes|Indirect|Indirect|Indirect|
|Table Data|Intelligent Cloud Status|Yes|Indirect|Indirect|Indirect|
|Table Data|Scheduled Task|Yes|Indirect|Indirect|Indirect|
|Table Data|OData Edm Type|Yes|Indirect|Indirect|Indirect|
|Table Data|Media Set|Yes|Indirect|Indirect|Indirect|
|Table Data|Media|Yes|Indirect|Indirect|Indirect|
|Table Data|Media Resources|Yes|Indirect|Indirect|Indirect|
|Table Data|Tenant Media Set|Yes|Indirect|Indirect|Indirect|
|Table Data|Tenant Media|Yes|Indirect|Indirect|Indirect|
|Table Data|Tenant Media Thumbnails|Yes|Indirect|Indirect|Indirect|
|Table Data|Entitlement Set|Yes|Indirect|Indirect|Indirect|
|Table Data|Entitlement|Yes|Indirect|Indirect|Indirect|
|Table Data|Membership Entitlement|Yes|Indirect|Indirect|Indirect|
|Table Data|Token Cache|Yes|Indirect|Indirect|Indirect|
|Table Data|Webhook Subscription|Yes|Indirect|Indirect|Indirect|
|Table Data|Published Application|Yes|Indirect|Indirect|Indirect|
|Table Data|Application Object Metadata|Yes|Indirect|Indirect|Indirect|
|Table Data|Application Resource|Yes|Indirect|Indirect|Indirect|
|Table Data|Application Dependency|Yes|Indirect|Indirect|Indirect|
|Table Data|Installed Application|Yes|Indirect|Indirect|Indirect|
|Table Data|Designed Query Obj|Yes|Indirect|Indirect|Indirect|
|Table Data|Privacy Notice|Yes|Yes|Yes|Indirect|

</details>

The reason for those tables being restricted to indirect, is the license. Thats also the reason why those errors never get noticed during development, because the developer license does not have those indirect restrictions.

And since licensing can change at any time, especcially in the cloud, we can never be sure that this list is finite and wont change.

## My solution to the problem.

If you want to, you can watch me build out the rule here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/0IJZwOd_lHQ?si=Z1v_QiwqRr4K-am-" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

But long story short: There is simply no way to know which tables absolutely need to have the `Permission` property set correctly to prevent those runtime errors.
Except for just always applying it for all reads, modifies, inserts and deletes. 

So I wrote the linter rule to identify those database accesses and to inform the developer that there should be a Permission set. 
The also handles inherent permissions both set on the table directly as well as the procedure scoped inherent permissions. If those are set, no indirect permissions should be needed. 
Reports and XMLPorts should also be handled correctly, reports only care about reads, while XMLPorts can also sometime import data, therefore need insert, modify and delete as well.

But all that should be detected correctly by now.

The only thing, that does not get detected, is any database operation done with `RecordRef`, since there is not really a reliable way to always know at compile time, which record is accessed.

### Extension objects

One major point of discussion was the fact that the `Permissions` property does not exist on `pageextensions` or `tableextensions`. I do not have any idea what the reason for this is.

And the linter cop does still inform for table data access on extension objects even though it can not really be fixed in place. 
The reason for this is, that a runtime error will still occur if you happen to hit one of those 250 tables I listed above, even if you access it on an extension object.

The only solution to this really is to move the code that does the data access out of the extension object into a Codeunit, and set the `Permission` correctly.

There where discussion on splitting the rule into two rule to make it easier to comply with the "main" rule, and to prevent the need to move tons of code. While I do understand the reasoning behind this, I am still not convinced that this is the right approach. Personally, I would probably disable the rule for large legacy projects alltogether if there is no intend to refactor the entire codebase. At least for the Pipelines I would disable this. In VS Code it could stay active if a developer works on a new feature inside the project. 

## Is that all?

There is something else. Let me first explain how indirect permissions work:

The idea is that a user does not always need direct permissions `RIMD` but sometimes might just have indirect permissions `rimd`.
For example: 
A user might be allowed to work with customers. He can create new ones, edit of course, and also delete customers. Per his permission sets. But this user is not allowed to look at Posted Sales Invoices. So he does not have direct read permissions on the Sales Invoice Header and Lines. 
Yet, he should be able to view selected information about invoices, maybe some totals or statistics that are placed in a FactBox on the customer card.

He should be able to indirectly read sales invoice information. For this to work the permission set need to have indrect read access specified to Sales Invoice Header and Lines and its crutial that the the `Permissions` property in code is set correctly, because thats a benefitial part in making the indirect permissions concept work at all.

## My Conclusion

It all started with avoiding permissions errors on those tables which are restriced by the users license. But as I learned a bit more and also thought a bit more about indirect permissions, I honestly think that the Permissions propery should always be set in code to cover just all data access operations.

The linter cop is all about clean code, this is one step torwards more clean code. I also disabled that rule for some of my larger/older projects because I can simply not uptake it right now. If you do care about this piece to comply with the permissions model that Business Central has, I think you should activate this rule. Since without setting the permissions, Admins and Users can simply not use indirect permissions.

Thats all, I hope this helps :)