---
title: 'My journey to Linux'
date: Thu, 08 Jun 2023 19:46:33 +0000
draft: false
tags: ['Allgemein']
---

I do not exactly recall when that thought started to grow in the back of my mind, but I think I always were fascinated by linux. And I already created linux live USB sticks a couple of times. It not that difficult anymore as I recall it was someday. Maybe it never was and I just became more savvy with tech, who knows. But I never felt like this could be the operating system I would use for my daily work.

So what changed? This time, I think it started when I realized I want to have a cleaner separation of my systems. Since I went freelance, I need to (and I can) decide for myself which environment I want to have to work on. This starts with the hardware, but I can also decide which software to work with. While most companies do not really care about which IDE you use to develop, as long as you comply with licenses, I dont think most companies give free choice when it comes to the OS you work on.

This meant for me, that if I dont want to by hardware twice, I need to have some kind if separation. Thr first thing that comes to mind are VMs, lets just create a new VM for each purpose and everything is clean. But I did not feel comfortable with the idea to run windows inside windows. I mean, there is so much going on in the background, and having this twice? Meh. So I started googling. And I came across this guy: Chris Titus

https://youtu.be/Kq849CpGd88

And after seeing this, I needed to give it a try. So I installed an Ubuntu instance on a spare SSD I had and gave it a try. And I was able to reproduce the boot times and felt the speed.

But now what? I mean windows docker containers wont run in linux, thats a fact. So a windows VM is needed to host docker for my Business Central containers. But then again, all that overhead just sitting there, only to host my docker? Again Chris comes to the rescue!

https://youtu.be/PYOsevW3KdA

In this video he explains how you can edit a windows .iso to exclude “features” you dont need. I used this to remove everything I could think of thats not needed for a windows VM which only has the purpose of hosting docker. Windows Hello, Cortana, IIS, Search, just to name a few from the top of my head. But most importantly: Defender! Yes, you can remove it. It wont enable itself automatically again, because its not even there.

But be cautious about removing the Defender. I am running my VM in a NAT so it can’t access any other PC in my network. And I dont browse the internet on this machine. But if you are unsure, better keep it ;)

But one thing still was left. I could install the AL language in VS code but it did not load the project. And there where like only two commands available. But I did recall that Andrzej Zwierzchowski mentioned something about the AL language extension and linux. So I texted him on twitter and he guided me in the right direction. Without his help, I am not sure if I would have figured it out at all.

It turned out that since MS transitioned to .net core, the groundwork was already done to support linux. Since .net core is available natively on linux. So I got that installed and just needed to repoint the al language server in two places and it worked.

Fortunately, if you want to give it a try yourself, you do not need to patch your AL language extension manually anymore. I created a mini extension for vs code to do that for you: [Marketplace](https://marketplace.visualstudio.com/items?itemName=StefanMaron.allanguagelinuxpatcher)

And with this, I was able to run VS Code to write AL, and I could run my docker containers. I am also running another Ubuntu VM for my daily work. That way have a rather clean host.

In the end I dont know if this was just min maxing or if this actually gives me a better performance, since I never tried to build this environment in Windows. But even if I just did it to have some fun or to prove that it actually works, being 3 months in now, I am not sure if I could go back. I did not delete my windows installation yet, it is still there, but I never booted it up ever since.

So much for now. Please let me know in the comments if this whole topic is interesting to you and if would like to hear some more about it, possibly also some more technical details and challenges I came across.