---
layout : post
title  : "Five years in Linux"
date   : 2026-11-03 00:01
tags   : [Linux, Hardware]
description: "Five years after Two Years in Linux: the desktop war ended, the stack won, and the terminal mattered again."
---

Five years ago this month, I published [Two years in Linux][1]. It
ended with a compromise: visual prettiness and access to proprietary software,
traded for an operating system that worked. I meant it then, and I still mean it
now. What I did not expect was that the compromise would stop feeling like one.

<!--more-->

The short version of that post: Windows annoyed me, macOS frustrated me, Linux
Mint was the first thing that felt like mine, Manjaro with KDE was the honeymoon,
and Arch with a tiling window manager was the move. The good: the package
manager, the UNIX tools, and the privacy. The bad: MS365 and Adobe. The ugly:
HiDPI on Xorg and a Wayland session that was not ready.

Five years later, two of those three verdicts have held, one has changed, and
the thing I thought was the point turned out not to be.

## The desktop war ended and the stack won

In 2021 the argument was GNOME versus KDE. In 2026 the argument is whether a
distro should have opinions at all.

GNOME and KDE did not collapse. They became institutions: release schedules,
design teams, governance, a position on every discussion. That is not a failure.
It is what happens to a desktop that has to serve millions of people with
different needs. But institutions are not where the energy comes from, and this
year the energy moved somewhere else.

[Omarchy][2] is the clearest example: Arch, Hyprland, a set of opinionated
defaults, and a website that calls itself "agentic Linux". It has more than
46,000 GitHub stars and 1.3 million ISO downloads in its first year. [Hyprland][3]
and [Niri][4] made tiling compositors legible to people who had never edited a
config file. [Noctalia][5] and [Dux][6] turned the desktop shell into a thing you
choose, the way you choose a terminal emulator. Omarchy is opinionated, but what
it ships is a stack — compositor, shell, terminal, editor, agent — not a desktop
environment with a settings panel.

That is not the same as Linux taking over the desktop. [Linux is over five per
cent of desktops][9] by StatCounter's count. But market share is no longer the
interesting number: **the momentum moved, even if the market did not.** The
people building the desktop I want to use are no longer in a GNOME design
meeting.

## The stack replaced the desktop

The unit of customisation used to be the desktop environment. Now it is the
stack: compositor, shell, greeter, dotfiles, and the handful of services you
actually run.

[Quickshell][7] made the shell a real application: a bar, a launcher, a lock
screen, notifications, a settings panel, all in one project. Noctalia is no
longer just a bar: the project now spans a shell, a compositor called Umbriel, and
a login screen, all sharing one palette and one philosophy. Dux Shell supports
Niri, Hyprland, Sway, MangoWC, labwc, and MiracleWM — the shell is portable
across compositors in a way a desktop environment never was.

The same thing happened to window managers. Hyprland, Niri, Sway, River, Wayfire,
and the tiling mode inside Cosmic all exist, and most of them are one person's
opinion about how windows should move. That is the explosion: not a new desktop
environment, a new layer underneath the one we had.

## The Wayland holdout

I still run [qtile][8] on X11, with picom for compositing. It works. I know the
keybindings, the config is Python I can read, and I have never had a session
where the screen sharing broke because a portal decided not to exist.

Five years ago Wayland was the ugly part of the post. It was going to fix HiDPI
and fractional scaling. It sort of did, and then it moved the problem: now the
question is whether your compositor, your shell, your screenshot tool, and your
video call all agree about the same protocol. X11 is old and ugly, but it is
boring in a way that I have learned to appreciate.

And yet. Omarchy, Hyprland, Noctalia, and Dux are all Wayland. For the first time
the reason to switch is not ideology or a feature matrix; it is that the other
side looks better. Noctalia is the first Linux shell I have seen in years that I
would install for the screenshots alone. Niri's scrollable tiling makes more
sense to me than another workspace grid. If I move, it will be because the stack
is finally worth the migration, not because someone told me X11 is dead.

I can still avoid Wayland and live my life. I am just no longer sure I want to.

## The terminal was the real bet

The part of the 2021 post I got most right was the least fashionable: the
terminal is king. Package managers, UNIX tools, Emacs, Docker, a tiling window
manager — all of it is text, and text is composable in a way that a settings
panel is not.

What I did not see coming was that this would become the most valuable property
of the whole system. Coding agents read text, run commands, inspect logs, and
edit config files. A Linux machine is a set of small, documented interfaces:
`--help`, man pages, `systemd`, `git`, `rg`, `fd`, `jq`, plain files in `~/.config`.
An agent can work with that. A GUI app is a closed box; a TUI is a protocol.

This is why "agentic Linux" is not just marketing. Omarchy is built around an
agent-first workflow: terminal-first, text config, and an agent you can point at
the repo. The same properties that made Linux good for me in 2021 made it good
for the tools I use in 2026. I wrote about the policy side of that
[elsewhere][12]; this is the practical side.

It would be too neat to credit agents for Linux's growth. The bigger driver is
games. But agents make the terminal more valuable than it has been in years, and
that is a tailwind nobody was predicting five years ago.

## Everyone else arrived through Steam

I do not play games. I still have to mention this, because it is the biggest
thing that happened to the Linux desktop in the last five years.

Valve shipped the new Steam Controller in May 2026 and the [Steam Machine][10]
in June — a console-sized PC that boots SteamOS — with the Steam Frame following
in September. The Machine starts at $1,049, a price the RAM market shaped as much
as Valve did. [Linux briefly passed five per cent of Steam users][11] in March
2026 before settling back around four, and the distribution chart is the
interesting part: CachyOS and Arch, both Arch-based, are now a serious slice of
Linux gamers. The distro people choose when they care about performance is the
same family as Omarchy.

Valve did more for the Linux desktop than a decade of desktop-environment
arguments. Not because SteamOS is a purist's dream, but because it shipped
hardware that normal people bought, and the software underneath happened to be
Linux. That is how adoption works: through a product, not a principle.

## What I got wrong

I thought Wayland would fix HiDPI and make me switch. It fixed some of it and
made the rest someone else's problem. I still avoid fractional scaling.

I thought the big desktops would either win or collapse. They did neither. They
became infrastructure, which is a stranger and more durable outcome.

I thought the "year of the Linux desktop" would arrive through people switching
on principle. It arrived through handhelds, a console, and a terminal that agents
can read.

And I thought I cared about desktop environments. I care about shells, config
files, and the layer underneath. The desktop was never the point.

## Five more years

The next five years are probably about three things: agents that can actually
drive a machine, ARM laptops that do not make me compromise, and distros
opinionated enough to be useful without becoming a personality cult.

I would like to finally switch to Wayland. I would like my dotfiles to survive
the move. I would like the desktop I use to be built by people who still care
about the thing they are shipping, rather than the committee that approves it.

Five years ago I switched because Windows annoyed me. I stayed because Linux is
the only operating system that lets me build the machine I want. That is still
true. The difference is that, for the first time in a while, the machine other
people are building looks worth copying.

[1]: https://davidbudzynski.github.io/2021/10/25/two-years-in-linux.html
[2]: https://omarchy.org/
[3]: https://hypr.land/
[4]: https://github.com/YaLTeR/niri
[5]: https://noctalia.dev/
[6]: https://github.com/duxlabs-dev/dux-shell
[7]: https://quickshell.org/
[8]: https://qtile.org/
[9]: https://gs.statcounter.com/os-market-share/desktop/worldwide
[10]: https://store.steampowered.com/hardware
[11]: https://www.gamingonlinux.com/2026/08/linux-back-over-4-percent-in-the-july-2026-steam-survey/
[12]: https://davidbudzynski.github.io/2026/10/31/no-ai-open-source.html
