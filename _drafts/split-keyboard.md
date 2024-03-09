---
layout: post
title: "Split Ergonomic Keyboards and Touch Typing"
date: 2024-03-09 16:15
---

![Cantor split keyboard](/assets/images/IMG_0173.JPG)

In July last year I started thinking about getting an ergonomic split keyboard.
Many people choose to get a split keyboard because they are more comfortable to
type on, easier to customize, and often have a smaller footprint than
traditional keyboards. I had been using a mechanical keyboard for a few years
and I was starting to feel that my hands were getting tired after a long day of
typing. This is because the majority of mechanical keyboards are quite tall and
have the traditional mechanical switches such as Cherry MX Browns. I had heard
about split keyboards before, but I had never really considered them. I thought
that they would be very complicated to put together and too much trouble
overall.

I started to do some research and I found that there were many different types
of split keyboards, some of them were very expensive and required many parts,
and some of them were very cheap (relatively speaking), designed specifically to
streamline the assembly process and keep the cost down. My goal was to learn to
touch type, have a nice small keyboard which I can take with me if I travel or
go to the office and to be able to utilize the programmability of these
keyboards, so I can assign keys how I like. I decided that I wanted to build my
own split keyboard, and I started to look for information on how to do it. My
research concluded that there were 3 options which would be ideal for me:
[Lilly58][1], [Corne][2], and the [Cantor][3]. I decided to go with the Cantor
because it was the cheapest overall and required the least amount of parts.

The Cantor is a 40% split keyboard with 42 keys. It was inspired by Corne and
other similar keyboards, but it has a stronger column stagger which is useful
for those with larger hands, like mine.It is a very simple keyboard and it was
designed like that on purpose to keep the price low and the assembly process
simple.

## Hardware

The Cantor repo on Github contains all information you need. Almost every part
with the exception of the PCB can be bought from Aliexpress. The PCB can be
ordered from either JLCPCB or PCBWay. I ordered mine from JLCPCB and it cost me
£16.47 for 5 PCBs. All parts cost me £80.61, but the the price per one assembled
keyboard was around b£66. Some of these parts are sold in lots, so you are left
with a few spare ones, but there is no other way of getting around this, unless
you order a DIY kit from vendors who sell those. Ordering parts from Aliexpress
is still a cheaper way to buy them compared to those kits! I wanted to try
building one keyboard and perhaps in the future experiment with more, so I went
this route. There are however vendors who sell pre-assembled keyboards, so if
you do not mind paying extra for this service, this is a good way to check if
this sort of keyboard is for you. Here is a table with the parts and their
prices:

| Item                                                           | lot qty | qty per kb | lot price | per kb price |
| -------------------------------------------------------------- | ------- | ---------- | --------- | ------------ |
| Cantor PCB                                                     | 5       | 2          | 16.47     | 6.588        |
| STM32F401 Blackpill Controller                                 | 2       | 2          | 6.96      | 6.96         |
| TRRS Cable                                                     | 1       | 1          | 3.92      | 3.92         |
| TRRS Port                                                      | 10      | 2          | 2.61      | 0.522        |
| Khail Choc Brown Key Switches                                  | 50      | 42         | 26.3      | 22.092       |
| PBT keycaps                                                    | 50      | 42         | 22.43     | 18.8412      |
| 6mm x 2mm rubber feet                                          | 100     | 16         | 2.15      | 0.344        |
| Soldering kit (soldering iron, soldering silicone mat, solder) | 1       | 1          | 6.77      | 6.77         |
| Total price                                                    |         |            | 80.61     | 66.0372      |

## build process

### soldering

Unlike all keyboards that you can buy from a store, the Cantor is a DIY, so you
need to be comfortable with soldering, or you need to learn how to do it. I had
never soldered before, so I had to learn how to do it. I watched a few videos on
youtube and I thought that it isn't that complicated. If you are in the same,
position like I am, I would recommend you to buy a soldering kit which contains
thin solder wire 0.5mm or thinner. Anything thicker and it will be difficult to
contain how much solder you put and you can end up ruining your PCB or other
parts. I also recommend you to buy a silicone mat and a magnifying glass. The
mat will stop you from burning your table and the magnifying glass will help you
to see what you are doing. I didn't buy a magnifying glass and I regret it.
After staring at tiny PCB elements for a couple of hours my eyes were tired and
I was beginning to make mistakes by trying to finish the job quickly.

The entire build process took me about 6 hours. Fortunately, Cantor's build
guide is very straightforward and easy to follow. Once you do one part, the
other one is much easier.

### flashing the firmware

Cantor uses [QMK][4] firmware, which is a very popular firmware for custom
keyboards. It allows for a lot of customization and it is very easy to use. You
can use [QMK configurator][5] to create your layout, or you can write it in C.
There are also alternative configurators such as [VIA][6] or alternative firmware
such as [Vial][7] which comes with its own GUI. I decided to use Vial, because it is
very easy to use, does not require re-compiling the firmware each time you want
to change something, and it has a nice GUI. I think that the default key layout
on Cantor is terrible and you really need to spend some time to figure out what
you want. I spent a few days looking at different options and I started with a
layout similar to the default Corne layout.

To compile and flash the firmware onto controllers (you need to do it for both
sides) you need to clone the [qmk-vial repository][8], go inside the directory
and run the following make command after plugging the controller into your
computer:

```bash
 make cantor:vial:flash
```

Remember to repeat this process for the other side of they keyboard on the other
controller.

If you are not on Linux, you can use the GUI to flash the firmware. Download the
[QMK Toolbox][9] and flash a binary which you can download from this [website][10]
Disclaimer: I have not tried this method and cannot guarantee these binaries
weren't tampered with, so use your own judgement.

## Software

- mention qmk and vial, custom layouts, layers, ability to swap many layout types, touch typing,

Once you have done this, you can plug the controller which will be the master
into your computer and use the GUI or a chromium-based browser [configurator][11]
to configure your layout.

After few trials and errors, I ended up with a layout that I was happy with. It
looks like this (each picture is a different layer):

![keyboard layout layer zero](/assets/images/2024-03-09_15-56_keeb-layout-layer-0.png)

![keyboard layout layer one](/assets/images/2024-03-09_16-02-keyboard-layout-layer-1.png)

![keyboard layout layer one](/assets/images/2024-03-09_16-03-keyboard-layout-layer-2.png)

![keyboard layout layer one](/assets/images/2024-03-09_16-04-keyboard-layout-layer-3.png)

## Learning to touch type

-monkey type and other touch typing sites

## conclusions

[1]: <https://github.com/kata0510/Lily58>
[2]: <https://github.com/foostan/crkbd>
[3]: <https://github.com/diepala/cantor>
[4]: <https://qmk.fm/>
[5]: <https://config.qmk.fm/>
[6]: <https://www.caniusevia.com/>
[7]: <https://get.vial.today/>
[8]: <https://github.com/vial-kb/vial-qmk>
[9]: <https://github.com/qmk/qmk_toolbox>
[10]: <https://keyboard.gay/>
[11]: <https://vial.rocks/>
