---
title: 'Can I copy my container?'
date: Tue, 23 Feb 2021 05:58:14 +0000
draft: false
tags: ['Allgemein', 'Docker', 'Powershell']
---

I just stumbled over this twitter post from Steve

![](https://stefanmaron.files.wordpress.com/2021/02/image-3.png)

And I asked myself the same question already some time ago. And guess what, this is super easy ;)

Stop and Commit the container you want to copy
----------------------------------------------

You first need to stop your container you want to copy. If it is running of course ;)

```
Stop-BcContainer <ContainerToCopy>
```

This should not take too long.  
After that you can use the "Docker commit" command to save the current state of this container to a new image.

```
docker commit <ContainerToCopy> backup:containertocopy
```

"backup:containertocopy" is the name of the new image. If you have the docker extension for vs code you will see your image in the side bar like that:

![](https://stefanmaron.files.wordpress.com/2021/02/image-4.png)

Create a new container from the image
-------------------------------------

I created a simple script with the New-BcContainerWizard for you to reuse. Note that you only need to pass your image name to the New-BCContainer command. The artifact url you dont need in this scenario ;)

```
$containerName = 'CopyOfSavedContainer'
$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$licenseFile = 'PathToYourLicenseFile'
New-BcContainer \`
    -accept\_eula \`
    -containerName $containerName \`
    -credential $credential \`
    -auth $auth \`
    -imageName 'backup:containertocopy' \`
    -licenseFile $licenseFile \`
    -memoryLimit 8G \`
    -updateHosts
```

This also should speed up your container creation process a lot as nothing needs to be installed inside the container ;)

![](https://stefanmaron.files.wordpress.com/2021/02/image-5.png)

Thanks for reading!