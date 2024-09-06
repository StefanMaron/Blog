---
title: "Excel Reports OnPrem/Docker"
date: 2024-09-06T06:43:14+02:00
draft: false
---

This blog is about how to get your Excel report layout connected to have a refreshable Excel report.
But with Docker and OnPremise ;)

The idea and the base for this is Tonyas blog, if you did not read that already, I highly recommend you do so:  
https://bcdevnotebook.com/2024/04/30/the-comprehensive-guide-to-using-business-central-excel-report-metadata-with-refreshable-apis/

Alright, now lets get to it.

First, of course, we need a docker container. If you dont know at all how to prepare your machine to be able to run Business Central docker containers, you might need to read up on that before you continue here.  
https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-running-container-development
https://vld-nav.com/bc-docker-quick-start-guide

And probably other resources ;)  
https://letmegooglethat.com/?q=business+central+docker+setup

Now, I use this script to create my container, if you dont have a go-to script, you can of course use mine:

``` powershell
$containerName = 'BC24-dev'
$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'sandbox' -country w1


New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -image my `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -isolation process `
    -updateHosts `
    -includeTestLibrariesOnly `
    -includePerformanceToolkit
```

Now after you created your container, log into the web client and run any report to download the Excel Template.

![RequestPageSaveAsExcel](/images/RequestPageSaveAsExcel.png)

After that you can open the Excel sheet. Like Tonya explained, you need to grab the OData feed from the BC API.
By going to Data>Get Data>From Other Sources>From Odata Feed

Now the URL depends a bit on how your docker Container was created, in my case its:

`http://bc24-dev-default:7048/bc/api/v2.0`

Now, please note how this is contructed:

`http://{ContainerName}-{TenantName}:{OdataPort}/bc/api/v2.0`

If you use sandbox container, like me, you need to specify the tenant.
I first tried to do this by adding the query paramtere `?tenant=default` but excel does not like this at all.
I dont remember where I found the information to add the tenant name like this, but now its here on my blog as well :)
If you are using onpremise containers or single tenant containers, you dont need this.

After you entered the url in the request window, it will complain about missing permissions.
For docker you can just use the standard login method with username and password credentials:
(Sorry for the German :D)

![ExcelAPILoginScreen.png](/images/ExcelAPILoginScreen.png)

Then you will be presented with the different endpoints available already. 
And from here its again exaclty like Tonya explained for the sandbox environments :)

I hope this helps to get the APIs tested in docker containers!