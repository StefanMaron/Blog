---
title: 'How to: Fix problems with Docker DNS resolution'
date: Sat, 04 Jul 2020 17:53:29 +0000
draft: false
tags: ['Business Central', 'BusinessCentral', 'DNS', 'Docker', 'Powershell']
---

Recently I discovered that my BC instance within a Docker container somehow can not access the internet. After some time I figured that the problem was the DNS resolution and I thought I might share two possible ways to resolve this problem with you!

#### How to check if you have the same problem

You can check this by yourself if you enter you BC Container. (Note: You need to have the [navcontainerhelper](https://github.com/microsoft/navcontainerhelper/blob/master/NavContainerHelper.md#get-started---install-navcontainerhelper) module installed)

```
Enter-BCContainer <your\_container\_name>
```

After that you can ping google:

```
ping google.com
```

![](https://stefanmaron.files.wordpress.com/2020/07/image-1.png)

#### My first attempt: Change the metric of the network interfaces

In my case the problem was a VPN I installed locally on my laptop. Normaly you want your laptop to prioritize traffic to go trough your VPN if it is active. To do so Windows uses a priority setting on your network adapters called "metric". The lower the metric of a interface the higher is its priority. Normally, if your interface metric is set to automatic, your LAN interfaces have a metric of 25 (At least in my case ;-) ). And my VPN interface had a metric of 5.

You can look up your interface metrics via Powershell:

```
Get-NetIPInterface -AddressFamily IPv4 | Sort-Object -Property InterfaceMetric -Descending
```

This is how it looks for me:

![](https://stefanmaron.files.wordpress.com/2020/07/image.png)

Now it is important to know, that Docker uses the DNS settings from the host and it seems to use the interface with the highest priority for this.

So what I did was simply to change the metric of my interface to be the lowest. For me this is my W-LAN Interface right now. You can identify the correct one for you by the "ConnectionState" column.

Again Powershell to the rescue:

```
Set-NetIPInterface -InterfaceIndex 22 -InterfaceMetric 1
```

After the metric is changed I just needed to restart my Docker containers and the DNS resolution worked again.

#### Second attempt: Give Docker a different DNS server

So the first attempt did not satisfy me. There needs to be an easier ways to solve this. And there is!

After another session with google it turned out that you can simply tell docker which DNS server to use and just add this to your config:

```
"dns": \[
    "8.8.8.8"
  \]
```

Note: I use the public google DNS Server. You can of course use another one or even multiple, as this setting is an array ;)

![](https://stefanmaron.files.wordpress.com/2020/07/image-2.png)

Don't forget to "Apply & Restart" ;)