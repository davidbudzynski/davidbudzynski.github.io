---
layout : post
title  : "My dotfiles have stopped changing"
date   : 2026-11-10 00:01
tags   : [Linux, Tooling]
description: "GNU Stow, Doom Emacs, TUI tools, and OpenCode: the setup that survived by not being rewritten."
---

The highest compliment I can pay [my dotfiles][1] is that I do not think about
them any more. The repo still gets commits, but they are one-liners: a tmux
binding, a rofi theme, a path. The last real rewrite was years ago. This is what
maturity looks like, and why I stopped chasing dotfile frameworks.

<!--more-->

Part of that is deliberate. Part of it is the RAM market. I have not built a new
PC in years because the prices are absurd, and a new machine is the usual excuse
to rewrite everything. Without that forced migration, the setup got to age in
place. The things I actually use survived; the things I configured for a
hypothetical workflow quietly rotted. That is a better test than any refactor.

## Stow is the whole framework

The repo is a shadow of `$HOME`. Each top-level directory is one program, and the
files inside it sit exactly where they would sit in your home directory. Here is
a slice of it:

```
dotfiles/
├── alacritty/.config/alacritty/alacritty.toml
├── bin/
├── doom/.config/doom/
├── ghostty/.config/ghostty/
├── picom/.config/picom/
├── qtile/.config/qtile/
├── rofi/.config/rofi/
├── tmux/.config/tmux/
└── zsh/.zshrc
```

[GNU Stow][2] creates the symlinks:

```bash
stow -t ~ zsh qtile alacritty
stow -D -t ~ qtile        # remove one package
stow -n -v -t ~ .         # dry run, show what would change
```

That is the entire mechanism. No installer, no templating language, no build
step. `git diff` tells me what changed, and `ls -l ~/.zshrc` tells me whether it
is live. When I want to try a new terminal, I add a directory, stow it, and
delete it if I do not like it.

I looked at chezmoi and Nix home-manager. Both are good tools. Both solve
problems I do not have: templating across many machines, secrets management,
generated configs, a declarative model of the whole system. I have a small number
of machines, and the differences between them fit in a handful of lines. A
symlink farm is cheaper to understand than a framework, and at this scale,
understanding is the feature.

The cost is real: Stow does not template, does not manage secrets, and does not
know which packages are installed. I install packages by hand, keep secrets out
of the repo, and accept that a fresh machine is an afternoon rather than a
single command. For me, that is the right trade.

## Emacs is the flexibility layer

I use [Doom Emacs][3], with the config in `doom/.config/doom` and a pile of
snippets for R and Org. The reason is not that Emacs is faster or prettier. It is
that Emacs is a programmable environment, not an editor with an extension API.

[Org mode][4] is where notes, drafts, and half-finished tables live. [Magit][5]
is how I do git; I have an alias that opens it in a terminal frame, and I rarely
type `git status` by hand any more. [Dired][6] is a file manager that happens to
be inside the editor. [TRAMP][7] edits files on a remote machine as if they were
local. When I want the editor to do something nobody shipped, I write a few lines
of elisp and move on.

VSCode is a great editor. It is also a product: the extension API is a boundary,
the marketplace is a supply chain, and the things you can change are the things
someone decided to expose. Emacs has no such boundary. That flexibility costs
maintenance, startup time, and the occasional afternoon in a stack trace. Doom
makes it tolerable. After a few years, the trade is worth it.

The dotfiles reflect that: the Emacs config is the largest directory in the
repo, and the one I touch least. It reached the point where it does what I need,
and the remaining changes are small.

## TUI utilities are the daily tools

The terminal tools are the part of the setup I would miss most. They are fast,
composable, work over SSH, and behave the same whether I am on the laptop or the
desktop.

- [tmux][10] for sessions and panes. It is also where the agent runs, which makes
  it more useful now than it was five years ago.
- [Yazi][9] for files, with ranger still around for the muscle memory. I wrote
  about [CLI file managers][13] separately.
- [fzf][11] for fuzzy everything: history, files, branches, processes.
- [ripgrep][12] for search, `fd` for finding, `bat` for reading, `eza` for
  listing. The modern replacements stuck because they are faster and the output
  is better, not because they are new.
- `ncmpcpp` and `mpd` for music without a GUI. It is a silly thing to maintain
  until you realise it has worked for a decade without an update breaking it.

A TUI is a text protocol. It composes with other tools, it works when the
graphical session does not, and an agent can read its output. That last property
used to be a nice accident. Now it is the reason the terminal is the most
future-proof part of the desktop. I made the longer argument in [Five years in
Linux][16].

## The newest entry is OpenCode

The newest thing in the setup is [OpenCode][8], the coding-agent harness. It runs
in the terminal, reads the same files, edits configs, runs tests, and shows me a
diff before anything lands. It fits the rest of the setup because it is text in,
text out.

The dotfiles were agent-readable by accident. Plain files, small scripts, a
`bin/` directory, no opaque database. Now that is a feature: the same repo that
rebuilds my machine is the context an agent needs to work on it.

I wrote about the policy side of AI contributions [elsewhere][14], and about why
I still read the diffs [here][15]. This is the practical version: the harness is
just another terminal tool, and it belongs in the same dotfiles repo as the rest.

## What maturity looks like

A good dotfiles repo converges. The signs are boring: fewer commits, a stable
core, a short list of annoyances you have decided to live with, and a README you
can read in a minute.

If I were starting again, I would do four things differently:

1. Start with ten files, not a framework.
2. Put it in git on day one, before it feels worth it.
3. Use Stow or plain symlinks until two machines genuinely differ.
4. Delete config you have not used in a year.

The goal is not a perfect setup. The goal is one you can rebuild and explain.
Mine is not finished, but it has stopped moving, and that is the best state it
has ever been in.

The dotfiles are boring. The tools they let me run are not.

[1]: https://github.com/davidbudzynski/dotfiles
[2]: https://www.gnu.org/software/stow/
[3]: https://doomemacs.org/
[4]: https://orgmode.org/
[5]: https://magit.vc/
[6]: https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html
[7]: https://www.gnu.org/software/emacs/manual/html_node/emacs/Remote-Files.html
[8]: https://opencode.ai/
[9]: https://yazi-rs.github.io/
[10]: https://github.com/tmux/tmux
[11]: https://github.com/junegunn/fzf
[12]: https://github.com/BurntSushi/ripgrep
[13]: https://davidbudzynski.github.io/2024/11/17/cli-file-managers.html
[14]: https://davidbudzynski.github.io/2026/10/31/no-ai-open-source.html
[15]: https://davidbudzynski.github.io/2026/10/30/why-i-still-read-diffs.html
[16]: https://davidbudzynski.github.io/2026/11/03/five-years-in-linux.html
