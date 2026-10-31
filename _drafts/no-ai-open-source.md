---
layout : post
title  : "No-AI open source is a self-own"
tags   : [AI, Software, Open Source]
description: "Airflow and Omarchy get it, GNOME can't decide, and the hobbyist contributor pays for the difference."
---

Two files tell the whole story. Apache Airflow's [pull request template][13]
asks, politely, whether generative AI helped write the patch, and leaves a box
for the tool's name. The [data.table][16] repository goes further: its
[`AGENTS.md`][1] tells coding agents, in capitals, that if they are asked to
write package code they **must stop now and report that this is prohibited**.

Same technology. One project treats an agent as a tool and a human as the
author. The other treats the tool as contamination. Only one of those is a
policy. The other is a purity ritual, and it is a self-own.

Around those poles sits everyone else. Omarchy, the Arch-based desktop that
went from niche to everywhere this year, [merged over a thousand agent-written
pull requests in three months][17]. GNOME's extension reviewers reject anything
that smells of a model while one of the project's security maintainers argues
that AI-found bug reports are too useful to refuse. The question was never
"AI or not". It is "filter or ban".

<!--more-->

## An agent cannot be an author

Let us start with the part everyone agrees on. An agent cannot be an author. It
is not a legal person, it cannot sign a licence, it cannot answer a review
question three weeks after the merge, and it cannot be blamed when the code
breaks in production. Authorship is accountability. Tools do not have it.

Airflow says exactly this. Its [`AGENTS.md`][2] instructs agents never to list
themselves as a commit co-author, and its [contributor docs][3] tell humans:
"Generally, it's fine to use Gen-AI tools to help you create Pull Requests for
Apache Airflow" — provided you understand the code, run the tests, disclose the
tool, and accept that "the final responsibility for the code in your PR lies
with you."

That is the whole policy. It is five lines, it is enforceable, and it does not
require anyone to divine whether a particular sentence came from a model.

The Apache Software Foundation, which is not exactly a hotbed of reckless
modernism, goes further. Its [generative tooling guidance][4] allows AI-assisted
contributions if the licence conditions are met, recommends a `Generated-by:`
trailer in the commit, and says plainly: "It is not in the interest of the ASF
to tell developers what tools to use."

If the foundation behind Airflow, Kafka, and a thousand other projects can make
that work, the bar for everyone else is not high. It is a checkbox and a
sentence.

Omarchy shows what the other end looks like. David Heinemeier Hansson, who built
it, says he would ["rather get an agent-written pull request to one of my
projects than I'd get one written by a human"][17]. He merged over a thousand in
three months, a lot of them from people who were not classical programmers, and
he no longer reviews the queue himself: agents summarise it and he makes the
merge call. That is not a free-for-all. It is a filter with a human at the end.

## The roll call

The projects that went the other way are not shy about it.

- [Zig][5] has the strictest rule of the lot: no LLM-generated code or prose, no
  LLM editing, no translation, no sharing the results of LLM brainstorming, and
  no talking about LLM use at all. It is also the one ban with a real
  explanation, so I will come back to it.
- [NetBSD][6] says LLM-generated code is "presumed to be tainted" and must not
  be committed without prior written approval from core.
- [Gentoo][7] declares it "expressly forbidden" to contribute any content
  created with the assistance of natural language processing tools.
- [QEMU][8] will "DECLINE any contributions which are believed to include or
  derive from AI generated content" — including ChatGPT, Claude, Copilot, and
  Llama.
- [data.table][9] bans LLM edits to anything that ends up in the package
  tarball, but allows them for `.github/workflows`, which is a fascinating place
  to draw the line between contamination and convenience.
- [immich][10] asks contributors not to open LLM-generated pull requests and not
  to write comments with one: "Communication should be between humans."
- [GNOME][14] is three policies in a trench coat: extension reviewers reject
  submissions with clear signs of AI generation while allowing AI as a learning
  aid, [Loupe][15] bans generative AI outright, and a GNOME security maintainer
  [argues][18] that AI-found bug reports are too useful to refuse — and that
  projects which ban them are no longer suitable GNOME dependencies.

Some of these are more defensible than others. QEMU and Gentoo at least have a
coherent legal argument: AI output provenance is unsettled, copyleft guarantees
matter, and a maintainer cannot certify a licence they cannot trace. I do not
think they are stupid. I think the policy is, and those are different things.

The unenforceable details give the game away. QEMU bans contributions
*believed* to be AI-derived, which is a vibe with a licence footnote. data.table
draws the line at whether a file ships in the tarball, as if a language model
becomes harmless when it edits a YAML file. GNOME will reject an extension for
looking generated but accept a vulnerability report found by a model, which is
not a principle; it is a triage decision wearing a policy's clothes.

And here is the bit nobody wants to say: none of these policies can be
enforced. A contributor who wants to use an agent will use one and not tell
you. The ban does not remove the tool. It removes the disclosure.

## The slop argument does not save it

The strongest case for the bans is not licensing. It is exhaustion, and it is
real.

In January 2026, Daniel Stenberg [ended the curl bug bounty][11]. The
confirmed-vulnerability rate had fallen from above 15% to below 5%: "Not even
one in twenty was real." AI-generated reports were drowning the real ones, and
debunking them was burning the team out. Log4j's maintainers reported the same
pattern in the comments.

That is a genuine crisis. But read the rest of Stenberg's post. Pull requests
were *not* curl's problem, because curl has tests, scanners, and two hundred CI
jobs. "We don't need to waste any human time on pull requests until the quality
is good enough to get green check-marks," he wrote. The filter does the work.

Airflow reached the same conclusion from the other direction. It caps
contributors without write access at five open pull requests, runs an automated
first pass with an explicitly AI-attributed triage comment, and sends only the
survivors to a human. Omarchy goes further: Hansson no longer reviews every
pull request himself; agents summarise the queue and he makes the merge call.
Same flood, different plumbing.

The lesson is not "AI ruined open source". The lesson is that projects which
never built a filter are now trying to use a ban as one. A ban is not a filter.
It is a sign on the door that says "we have given up on distinguishing good
patches from bad ones, so we will reject all of them in advance."

## The one ban I respect

Zig is different, and I will not pretend otherwise. Loris Cro's essay
[Contributor Poker and Zig's AI Ban][12] is the best argument for a ban anyone
has written, and it is not really about code quality.

The argument is that open source runs on an iterated game. You invest review
time in a newcomer, and later that person becomes a trusted contributor who
maintains the thing they touched. "You bet on the contributor, not on the
contents of their first PR." Ten-thousand-line drive-by PRs, hallucinations that
do not compile, and people who lie about using an LLM all break that game. If
you have a huge pool of contributors who do not present that risk, it is
"irrational for us to bet on LLM users", as Cro puts it.

That is a serious claim, and Zig is entitled to make it. It is also a choice
with a cost, paid by people who are not in the room. The cost is not borne by
the core team; it is borne by the person who had one good patch in them and used
a model to get it into a shape they could defend.

And the mentoring argument can survive without the ban. Seniors can use agents;
juniors can write their patches by hand and get the same review, the same
pairing, and the same path into the project. The thing that teaches systems
thinking is the review conversation, not the absence of autocomplete. If a
project wants to reserve hand-written work for newcomers, it can do that
explicitly. It does not need to pretend that a tool is a person.

Zig opting out entirely is a legitimate choice. It is not a universal one, and
not every project has Zig's pool of contributors to fall back on.

## The hobbyist tax

Here is who actually pays.

Most open source contributors are not paid maintainers. They have day jobs,
meetings, difficult clients, families, and about an hour at ten at night. They
write the patch because they use the software and want it to be better. A few
years ago, that hour bought a small fix. Now it can buy a small fix plus the test
coverage plus the documentation update, because the boring parts take minutes
instead of evenings.

A blanket ban tells that person their hour is not welcome if a model helped.
Not their slop, not their hallucinated PR — their patch, the one with a test and
a clear explanation, because of the tool they used to write it.

The maintainer's inbox does not get better under that policy. It gets quieter.
Quieter feels like peace for a while, and then it looks like a package with one
maintainer, no recent commits, and an archive notice.

## The career bit

Refuse the tools if you like. The market will not send a thank-you note. It
will send a redundancy email and hire the person who learned them.

That is not an argument for using AI badly, or for letting it write code you
cannot defend. It is an argument against exporting a personal purity choice to a
community of volunteers who cannot afford it. A maintainer can say "I do not
want to review this patch." A policy says "your work is unwelcome because of the
tool you used." Those are different sentences, and only one of them is about
craft.

## What a sane policy looks like

Airflow's rules, plus curl's filter, plus the ASF's licence guidance, cover it:

1. Humans are authors. Never list an agent as a commit co-author.
2. Disclose the tool in the pull request or commit (`Generated-by:`).
3. The human answers review questions and owns the code after merge.
4. Tests, static checks, and a small, coherent diff. No drive-by PRs.
5. Cap the queue, close the slop, automate the first pass. Ban behaviour, not
   tools.

That is it. No divination, no loyalty test, no pretending a YAML file is
cleaner than an R file. Just the boring work of holding a human accountable.

## Closing

The projects that matter in five years will not be the purest ones. They will be
the ones that kept the humans, kept the review bar, and kept the door open to
the person with an hour and a good idea.

You cannot ban a tool. You can only ban the people who admit to using it. That
is a strange way to run a community, and an even stranger way to run a
package that needs contributors.

[1]: https://github.com/Rdatatable/data.table/blob/master/AGENTS.md
[2]: https://github.com/apache/airflow/blob/main/AGENTS.md
[3]: https://github.com/apache/airflow/blob/main/contributing-docs/05_pull_requests.rst#gen-ai-assisted-contributions
[4]: https://www.apache.org/legal/generative-tooling.html
[5]: https://ziglang.org/code-of-conduct/
[6]: https://www.netbsd.org/developers/commit-guidelines.html
[7]: https://wiki.gentoo.org/wiki/Project:Council/AI_policy
[8]: https://www.qemu.org/docs/master/devel/code-provenance.html#use-of-ai-generated-content
[9]: https://github.com/Rdatatable/data.table/blob/master/.github/CONTRIBUTING.md#ai-policy
[10]: https://github.com/immich-app/immich/blob/main/CONTRIBUTING.md
[11]: https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/
[12]: https://kristoff.it/blog/contributor-poker-and-ai
[13]: https://github.com/apache/airflow/blob/main/.github/PULL_REQUEST_TEMPLATE.md
[14]: https://gjs.guide/extensions/review-guidelines/review-guidelines.html#extensions-must-not-be-ai-generated
[15]: https://discourse.gnome.org/t/loupe-no-longer-allows-generative-ai-contributions/27327
[16]: https://github.com/Rdatatable/data.table
[17]: https://lexfridman.com/dhh-2-transcript
[18]: https://blogs.gnome.org/mcatanzaro/2026/10/02/the-era-of-software-quality-or-the-era-of-ostriches
