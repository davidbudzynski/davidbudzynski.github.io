---
layout   : post
title    : "Why I use Firefox as my default browser"
date     : 2024-04-13 18:00
category : general
tags     : Web Software Privacy
---

## Firefox's popularity around 2010's

When I was growing up, Firefox was the browser to use. It was the most popular
browser (at lest in Poland), with a market share above 50%. It was fast, secure,
and customizable. It was the browser that you could trust. It was the browser
that you could make your own.

Fast forward to 2024, and Firefox's usage has been declining for years and years
and its users are often seen as a dying breed. But I still use Firefox as my
default browser. Why?

## Customization

Firefox is still the most customizable browser out there. You can change almost
every aspect of it, from the way it looks to the way it behaves. You can make it
look and feel exactly the way you want it to. You can make it yours. It is true
that developers are trying to make it more difficult to customize Firefox, but
it is still possible to do so if you know how.

### About:config

Firefox has a hidden configuration menu called `about:config` that allows you to
change a lot of settings that are not available in the regular settings menu.
Once these settings are changed, they are saved in a file called `prefs.js` in
your profile directory. This file is a simple JavaScript file that you can edit
manually if you want to. If you have a firefox account, it also syncs these
settings across all your devices. These settings allow you to increase your
privacy and security.

### userChrome.css

If you want to change the way Firefox looks, and I mean if you don't like any
elements of the UI, you can use `userChrome.css` file. This file allows you to
change the appearance of Firefox's UI using CSS. You can change the colors, the
fonts, the sizes, the positions, and the visibility of almost every element of
the UI. You can make Firefox look exactly the way you want it to. You can make
it yours.

I use a dynamic tiling window manager, so for many years I had a custom
`userChrome.css` that removed the title bar as well as the tab view (I opt for
vertical tabs which I'll get to later on).

If you search on github, you can find many `userChrome.css` projects with
thousands of stars. Lately, I've stumbled upon [Lepton][1]. This projects aims to make
the Firefox UI more minimalistic and modern. It's a great starting point. I only
removed the title bar and the tab view from it.

Speaking of using window managers, Firefox has this annoying feature where the
settings and right click menus show an ugly border around them. To fix this, you
need to add the following to your picom config (assuming you're using X11 based
window manager and picom as a compositor):

```bash
shadow-exclude = [
...
"class_g = 'firefoxdeveloperedition'"
...
];
```

Some other [Reddit threads][2] say that you need to add more parameters like so
(assuming that you're using standard Firefox):

```bash
shadow-exclude = [
...
"class_g = 'firefox' && window_type = 'utility'",
...
];
```

### Add-ons

I use a few add-ons that make my browsing experience better.

#### Privacy and security

First and foremost, I use [uBlock Origin][3] to block ads and trackers with the
help of [Privacy Badger][4]. To limit the amount of data facebook collects about
me when I am forced to use it, I use [Facebook Container][5]. I also installed
[Firefox Containers][6], which allow me to separate my browsing sessions into
different containers. This is useful when I want to log in to the same website
with different accounts.

#### Look and feel

I use [Vimium][7] to navigate the web using only the keyboard.
[Tree Style Tab][8] to have my tabs on the left side of the screen. My start page
is set to [Tabliss][9], which is a beautiful new tab page that shows a random
wallpaper from Unsplash. I also use [Dark Reader][10] to make websites dark,
which is easier on the eyes in dark environments. For spell checking I use
[LanguageTool][11], which is a grammar and spell checker that works in multiple
languages.

#### Youtube

 To limit my usage of YouTube, I use [SponsorBlock][12] to skip sponsored
segments in videos. I also use [Enhancer for YouTube][13] to make the video player
more minimalistic, without recommendations, play next, and playlists.

[1]: <https://github.com/black7375/Firefox-UI-Fix>
[2]: <https://www.reddit.com/r/FirefoxCSS/comments/nr5mqb/comment/h0enxnf/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button>
[3]: <https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/>
[4]: <https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/>
[5]: <https://addons.mozilla.org/en-US/firefox/addon/facebook-container/>
[6]: <https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/>
[7]: <https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/>
[8]: <https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/>
[9]: <https://addons.mozilla.org/en-US/firefox/addon/tabliss/>
[10]: <https://addons.mozilla.org/en-US/firefox/addon/darkreader/>
[11]: <https://addons.mozilla.org/en-US/firefox/addon/languagetool/>
[12]: <https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/>
[13]: <https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/>
