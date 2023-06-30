---
title: "Go Live Checklist"
date: 2023-07-01T00:33:39+02:00
draft: false
---

I am not sure if you where on BCTechDays 2023, or if you maybe already saw Jeremy's session on YouTube already.

If not, have a look, its worth your time:

{{< youtube T68OQ_Yd-S0 >}}


And from all the good stuff he talked about, I wanted to have a more detailed look at the GoLiveChecklist app he created. And since its all OpenSource, I just went to his [github](https://github.com/SpareBrainedIdeas/GoLiveChecklisting) and checked it out.

The purpose of this app is, to script any kind of check you want to do, in your Business Central company, before you go live.
So this is not about checking (testing) code, its about testing your data. And while the checks for the base app might be similar for many customers, there is always some checks that are individual.
For that reason, the app has a "framework" which lets you add more checks in a very easy way.

There is still a long road to go with the app, but the potential is definitely there.

So what I did, was just having a first look through the code to understand the architecture a bit better, and to see how far Jeremy already is.
While doing that I could not keep myself from applying some fixes and some minor chances, I felt would help at least in the long run :)

If you are interested, this is the PR I created: [Click](https://github.com/SpareBrainedIdeas/GoLiveChecklisting/pull/1)

If you care to watch, I did record it as well:

{{< youtube T7i2F5Q2S84 >}}
