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
