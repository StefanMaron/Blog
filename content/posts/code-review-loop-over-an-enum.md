---
title: 'Code review: Loop over an Enum'
date: Mon, 19 Apr 2021 09:57:13 +0000
draft: false
tags: ['AL', 'BusinessCentral', 'Code review']
---

So I came across this post from ThatNavGuy: [Looping Through Enum – That NAV guy (wordpress.com)](https://thatnavguy.wordpress.com/2021/03/12/looping-through-enum/)

He shows an example on how to loop over an enum. The goal is to have the enum pointing to the next value on each iteration.

Since this community is about sharing knowledge and learning from each other, I wanted to make a quick code review and show, how I would solve this task ;)

This is the original code:

```
local procedure EnumLoop()
var
    MyEnum: Enum "My Enum";
    EnumIndex: List of \[Integer\];
    iMax, iLoop : Integer;
begin
    EnumIndex := ScanSource.Ordinals();
    iMax := EnumIndex.Count();
 
    If iMax <= 0 then
        exit;
     
    iLoop := 1;
    repeat //loop here
      MyEnum := EnumIndex.Get(iLoop);
      iLoop += 1;
    until iLoop > iMax;
end;
```

Line 4: I would call the variable "EnumOrdinals" as the ordinals are assigned in line 7.  
Line 5: Nice that integer variables are combined declared in one line!  
Line 10: As "iMax" contains the result of a count, it can not be less than zero. I always try to be as exact as possible with conditions. Otherwise it could cause confusion.  
Line

The rest seems to be okay, but this whole function can be much simpler. If you are not familiar with the "foreach" command, have a look at the docs first: [AL Control Statements - Business Central | Microsoft Docs](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-al-control-statements#foreach-control-structure)

With this command I refactored the code to this:

```
local procedure EnumLoop()
var
    CurrSalesDocType: Enum "Sales Document Type";
    Ordinal: Integer;
begin
    foreach Ordinal in Enum::"Sales Document Type".Ordinals() do begin
        CurrSalesDocType := Enum::"Sales Document Type".FromInteger(Ordinal);
        // do stuff here with "CurrSalesDocType"
    end;
end;
```

Line 6: We get a list of the ordinals. With the foreach loop the "ordinal" variable contains the current value in each iteration of the loop.  
Line 7: With the function "FromInteger" we can convert an ordinal to an actual enum value. This is saved to the variable "CurrSalesDocType" for further usage in the current iteration.

EDIT: Turns out there is always a better way to do it:

![](https://stefanmaron.files.wordpress.com/2021/04/image.png)

Why does it matter? Both functions do exactly the same
------------------------------------------------------

The main goals are, to increase readability I think. With this, maintainability is also increased.

Code is only written once, but read often after. Not only by the one who wrote but also from others.

My tip is to always try to make your code as readable and obvious as possible. This will help others to understand your code and even help yourself to understand your code if you need to work on it after some time again.

That's all for now ;) Happy coding!