---
layout: post
title: "Two years in Linux"
date:   2021-10-24 13:34
category: general
---

## Interactions with other operating systems

Since my childhood, I used many versions of Microsoft Windows. When I went to college I didn't have much money, so I bought a cheap windows laptop which did the job. I have screwed it up by spilling beer on it, which resulted in a fried logicboard and me nearly losing my college assignment work. This was a great opportunity to build a much better spec PC, so I bought all the components and built my first computer, which in theory was able to run macOS (and become a hackintosh) - though that happened much later. I installed Windows 10 on it and I was happy, although I became more aware about embeded telemetry and privacy concerns expressed by other people on the Internet around the time when Windows 10 was announced.

Around that time I also bought my first iPhone and I immediately fell in love with it. I decided to try out one of the iMacs in the university library and I decided to give a hackintosh route a try. Somehow I managed to get it installed and I could tell that macOS was much more polished that Windows, which made me not want to touch Windows ever again. I also bought a MacBook which I still regard as a great machine.

### My gripes with macOS

I think macOS is a great OS for an *average* user. It gets unnecessarily complicated any time you want more control, or you want to do something your way instead of the Apple way of doing things. Because macOS doesn't come with any package manager, you need to rely on very slow [homebrew][1] package manager. Everything you download and want to install needs to be approved time after time. There is also no easy way to bootstrap your development environment easily (tweaking system settings on a new machine etc.). To give an example, one week ago my girlfriend asked me to help her install LaTex on her macbook. I thought installing it via hombrew will all that's needed. Turns out that once you install it, you need to add it to path manually, which didn't work in my case, and I had to install it by downloading MiKTeX distribution from a website, which solved a problem. And of course any installed that you download form the internet is treated as if it was a high security risk that requires you to confirm that you want to open that file.

## Dipping my feet in Linux

I think I started getting more and more intrigued by using Linux when I picked up web development. I decided to look at different distributions and pick one to run on my old laptop; I remember trying out [Ubuntu][2], but I really didn't like GNOME desktop environment, so I decided to give [Linux Mint][3] a try. Although my laptop was fairly old and it only had 4GB RAM, it works surprisingly fast. All the tools I needed worked like on any other OS, so I decided to start install it on my hackintosh and dualboot alongside macOS. For that task I picked up [Majaro][4] with [KDE desktop environment][5]. I liked it so much so that each time I had to choose between macOS and Linux, I'd go for the latter. About a year ago I build a new PC exclusively for Linux so I can do all data science projects I want on it. Right now I'm running [Arch Linux][6], which is a very minimalist distribution. I will discuss my choice in future posts. After using it full-time for about a year here's what I do and don't like about. 

## The good 

Linux is the best operating machine for software development. Due to having a robust package manager built into a distribution, you can easily get the software you need and manage your updates. Some of the best development tools were written with UNIX machines in mind, so programs like Emacs work much better that they do on Windows or macOS. Some other applications like Docker were written on and for Linux specifically, so everything works much better here. 

I like the fact that there is so much variety when it comes to different desktop environments. You can pick and choose the one you like the most, or if you don't like any of them, or feel like you don't need any of them, you can go for only a window manager, like I do myself. This helps you to trim down on unnecessary bloat that comes with stuff preinstalled, so you end up with only applications that you want and that you know what they're doing. 

One of the most important things that is uncommon among mainstream operating systems is privacy. It is in the DNA of open source operating systems like Linux, so there is no telemetry, no spying on you, and you are allowed to do whatever you like with your system. Linux won't start calling home all of a sudden and even if it did, people would be able to notice this and remove that part when compiling a kernel. 

Lastly, Linux doesn't suffer from all malware and viruses that are created for Windows, so your environment is much safer. 

## The bad 

The only drawback that I experienced from using Linux day-to-day is the fact that big proprietary applications such as MS Office and Adobe aren't available. This is not an issue with the operating system itself but people and many industries are used to certain type of workflows. My dayjob relies heavily on MS365 and it would be difficult to do some of that work on Linux. There are free an open source alternatives, but it takes time and effort to sway large oragnizations to start using these, especially if all they know is Windows. 

I also realize that although some distributions are very easy to use as someone who knows nothing about computers, it still might be difficult to solve some problems by using GUI only. Terminal is still king on Linux, so I can imagine that might be a deterrent for less technical folks.


## The ugly

The ongoing issue that has been recognized by other people is the HiDPI scaling on Linux, or issues with it. Because most distributions rely on Xorg, a very old display server created a long time before 4K monitors were commonplace, it's difficult to implement HiDPI scaling correctly. This is also exacerbated by the fact that there are 2 types of GUI applications on Linux: Qt and GTK and both work slightly different, so some applications require some tweaking to get them to scale. Xorg also doesn't allow different scaling factors on multiple displays, so you need to either go full in with multiple HiDPI displays or stay with standard monitors. To combat these issues, an alternative and potential successor is being developed, but that also doesn't solve fractional scaling problems among other things. 

## Epilogue

Concluding, I'm very happy that I made a switch to Linux. I can definitely say that my productivity as a developer increased and I feel that my privacy is being respected. Even though it isn't perfect, I think that everything in life is a matter of compriomise. On this ocasion, I'm ready to compromise the visual prettiness and access to proprietary software in favor of a highly functioning operating system that makes my life easier. In the future blogpost I will outline my desk setup and specific software I use, so stay tuned for that one. 

[1]: <https://brew.sh/>
[2]: <https://ubuntu.com/>
[3]: <https://linuxmint.com/>
[4]: <https://manjaro.org/>
[5]: <https://kde.org/>
[6]: <https://archlinux.org/>
