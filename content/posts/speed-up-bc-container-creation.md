---
title: 'Speed up BC container creation'
date: Tue, 16 Mar 2021 19:46:00 +0000
draft: false
tags: ['Business Central', 'Docker', 'Performance']
---

This is probably going to be a short blog again and chances are high that you already know what I am going to share. But if your are like me and did not know this little trick, its going to save you, and maybe your team, quite some time!

Since I do not run my pipelines on DevOps but on GitLab I am quite happy to use the Run-ALPipeLine command. When you supply the -imageName parameter it behaves the same way like New-BCContainer does. It creates an image and reuses it if it was created before.

Then I started to write tests for my app and I needed to include -installTestLibraries and you probable know the output.

Tons of lines of these:

![](https://stefanmaron.files.wordpress.com/2021/03/image-9.png)

After a few runs I still noticed those, and wondered: **Are the test libraries not included in the image?** The answer is **No!**

So each container you create, and each container your build agent creates, will install all test apps and libraries over and over again.

Now the solution ;)

```
New-BcImage -artifactUrl (Get-BCArtifactUrl -version 17.4) -imageName myown -includeTestToolkit -licenseFile "C:\\temp\\myLicense.flf"
```

You can created the image yourself first and specify to include the image! When you create a container next time you will notice this:

![](https://stefanmaron.files.wordpress.com/2021/03/image-6.png)

Even if you specify the -includeTestToolkit param in your container creation script, the apps will just be skipped.

**How much faster is this?**

Well, I compared it as good as I could on my machine and I got this results:

![](https://stefanmaron.files.wordpress.com/2021/03/image-8.png)

![](https://stefanmaron.files.wordpress.com/2021/03/image-7.png)

For me this is almost 3 minutes faster!

I hope you will get similar results ;)