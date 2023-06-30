---
title: 'Business Central and Multiline Fields'
date: Thu, 20 Aug 2020 05:07:52 +0000
draft: false
tags: ['Allgemein', 'Business Central', 'BusinessCentral', 'Tips&amp;Tricks']
---

This topic is probably as old as the RTC client. If you want to display a text field on a Page you will try for around two hours and then you will give up and maybe build a control addin to solve this.

In the web client this problem was not solved by now. We have fields with length up to 2048 but we are not able to display this.

If you go the normal way you use this:

![](https://stefanmaron.files.wordpress.com/2020/08/image-13.png)

But the result is frustrating:

![](https://stefanmaron.files.wordpress.com/2020/08/image-14.png)

Correctly! We get three lines of text. And I tried everything with groups and grids. It did not change.

But this post is not about how bad everything is, I want to present you a solution how this can be done better without any custom control addin.

![](https://stefanmaron.files.wordpress.com/2020/08/image-15.png)

I may introduce you to the "Microsoft.Dynamics.Nav.Client.WebPageViewer". This is an awesome small controladdin shipped by microsoft. You can not only embed webpages in Buisness Central but you can also pass your own html!

This is what you need to do:

```
usercontrol(UserControlDesc; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
{
	trigger ControlAddInReady(callbackUrl: Text)
	begin
		IsReady := true;
		FillAddIn();
	end;

	trigger Callback(data: Text)
	begin
		Description := data;
	end;
}
``````
var
	IsReady: Boolean;

trigger OnAfterGetCurrRecord()
begin
	if IsReady then
		FillAddIn();
end;

local procedure FillAddIn()
begin
	CurrPage.UserControlDesc.SetContent(StrSubstNo('<textarea Id="TextArea" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TextArea'').value)">%1</textarea>', Description, MaxStrLen(Description)));
end;
```

What did I do there?

The HTML Control I used is a simple <textarea>. With maxlength you want to limit the field to the length of you text field on you table. In my case this is 2048. With the style tag, I set width and height to the max size of the space there is for this control addin.

Now the magic: With the OnChange setting of the textarea I defined what happens if the content is changed. This does not happen on every letter you type but if the textarea looses focus. The TriggerCallback function then passes the content of this textarea to our "trigger Callback(data: Text)" function. There we can simply write the content back to the table field.

Feel free to try this and give me some feedback, maybe there is still something to improve!