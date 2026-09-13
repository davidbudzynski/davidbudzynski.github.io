---
layout : post
title  : "Why I still read the diffs my agent produces"
tags   : [AI, Software, Tooling]
description: "My agent writes most of the first draft, but the diff is where I decide what becomes mine — where I look closely, what I need to understand before I'm comfortable, and the hunk workflow I use to review it."
---

My agent writes most of the first draft these days. I still read every diff
before it becomes a commit. Speed was never the bottleneck — knowing what
changed, and why, is.

<!--more-->

## The diff is the contract

An agent turn is a proposal, not a result. The chat transcript tells me what
the agent *intended*. The diff tells me what it *did*. Those two are rarely
identical: a fix in one file comes with a drive-by refactor in another, a
dependency bump sneaks in, a config gets "cleaned up" without being asked.

Reading the diff is also how I stay able to work without the agent. If I
cannot explain a change in review, I will not be able to debug it at 11pm
when the agent is off and the tests are red. The diff is the last place where
I am still the author, so I treat it like one.

## Where I look first

Most agent output is boring in a good way, and it reads fast:

- Formatting, import sorting, and mechanical renames with no behaviour change.
- Test additions that pass and actually assert something, not just cover lines.
- Docstring and comment fixes where the code already does what the new text says.
- Small, well-scoped fixes where the diff is smaller than the explanation.

The common thread is reversibility. If the change is small, local, and easy
to revert, reviewing it takes seconds and I move on.

## Where I slow down

I rarely rewrite agent output wholesale. The point of reading is to understand
each hunk well enough to be comfortable owning it. These are the places where
I linger:

- Public API changes, migrations, and anything touching auth or permissions.
  I read those line by line until I could explain the naming and the error
  messages myself.
- Error handling. Agents love the happy path and swallow the rest, so I check
  the `else` branches and failure modes until the behaviour makes sense to me.
- Clever one-liners. If I have to squint, I stop and unpack the logic — even
  if the code stays as-is, I want to know what it does.
- Anything I cannot explain out loud. That is the real filter: if I cannot
  say why a hunk exists, I ask the agent, re-read, or dig until I can. Only
  then does it get committed.

This is not distrust of the tool. It is the same bar I used for human pull
requests — I just hit it ten times more often now.

## How I keep git hygiene

Agents are happiest when they can keep editing. I am happiest when the
history stays readable. The compromise looks like this:

1. One task, one branch, small commits. I review with `git diff` before
   `git add`, never after.
2. I split mega-diffs. If one agent turn touches three concerns, it becomes
   three commits, even if that takes an extra five minutes.
3. Lockfiles and generated files get their own commit so they never hide
   real changes.
4. Nothing gets committed straight from the agent's summary. The summary
   says "done". The diff decides.

## Hunk: a nicer place to do it

Plain `git diff` still works, but for agent-sized changesets I have started
using [hunk][1], a review-first terminal diff viewer built for exactly this
job. The project page is at [hunk.dev][2]. It is free and open source under
MIT.

Install on macOS or Linux with the standalone binary:

```bash
curl -fsSL https://hunk.dev/install.sh | sh
```

Alternatives are `brew install hunk`, `mise use -g hunk`, or
`npm i -g hunkdiff` if you already run Node.js 22+. Updates go through
`hunk update`, or your package manager if you installed it that way.

My daily loop is three commands:

```bash
hunk diff         # working tree, untracked files included
hunk diff --watch # auto-reloads while the agent keeps editing
hunk show         # review the latest commit, or hunk show HEAD~1
```

A few more that earned a place: `hunk diff --files before.ts after.ts` for
comparing two files directly, `git diff --no-color | hunk patch -` for
reviewing a piped patch, and `hunk log` for browsing history from the
terminal.

What makes it different from [delta][4] or [difftastic][5] is that it is
built for reviewing a whole changeset, not rendering one file prettily. You
get a multi-file stream with a sidebar, split and unified layouts that adapt
to terminal width, mouse support, syntax highlighting, and inline agent
annotations next to the code. `delta` is still the better pager for a quick
one-file look; `hunk` is where I go when the agent touched six files and I
need to walk all of them.

Two integrations are worth knowing. You can make it your Git pager so
`git diff` and `git show` open in it automatically:

```bash
git config --global core.pager "hunk pager"
```

One caveat from the docs: untracked files are auto-included by `hunk diff`
itself, but not when you go through `git diff` piped into `hunk pager` —
there Git decides the patch contents. And for agent-driven review there is a
skill workflow: open `hunk diff` in one terminal, run `hunk skill path` to
get the skill file, and tell your agent to load it. The full version is
documented in the [agent workflows guide][3].

## Closing thoughts

The agent made writing code cheaper. It did not make deciding what the code
should be any cheaper. Reading diffs is where that decision still happens,
and a decent review UI just lowers the friction enough that I actually do it
every time.

[1]: https://github.com/modem-dev/hunk
[2]: https://hunk.dev
[3]: https://github.com/modem-dev/hunk/blob/main/docs/agent-workflows.md
[4]: https://github.com/dandavison/delta
[5]: https://github.com/Wilfred/difftastic
