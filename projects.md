---
layout: page
title: Projects
permalink: /projects/
---

I don't keep a long list of side projects. Most of my energy goes into my
day job, so what I maintain outside of work is small on purpose: a few
things I actually use, plus the occasional upstream contribution.

## Things I maintain

### [This blog][1]

Jekyll site I've run since 2021. It's where I write up what I'm learning:
R and Python workflows, reproducible environments, Linux tooling,
self-hosting, and the occasional keyboard or CLI rabbit hole.

### [dotfiles][2]

My Linux setup: tiling window manager, shell, CLI tools, Firefox
customization. Nothing fancy, just the config I rely on every day, kept in
version control so a fresh machine takes hours, not days.

### [R-project-bootstrap][3]

A small R project template I use to start new analyses: Dockerfile,
Makefile, directory structure, and a few opinions. Inspired by the
[Cookiecutter Data Science template][4], trimmed down to what I actually
use.

## Upstream contributions

Most of my R work happens here — contributing to tools I already depend
on rather than starting new packages. I contribute as much as I can to
[collapse][5] and [kit][6] (both part of the fastverse), as well as
[data.table][7] — mostly performance and portability fixes and small docs
cleanups where I spot them.

## Day job

I work with data — day to day that's mostly Python, on top of a long R
background. Reproducible workflows, Docker and [renv][8] for environments.
I can't share that code, but I write up the generalizable parts here. A few
examples from the R side:

- [Docker for R projects][9]
- [renv vs Docker: when to use each][10]
- [Why R is a terrible language][11]

[1]: https://github.com/davidbudzynski/davidbudzynski.github.io
[2]: https://github.com/davidbudzynski/dotfiles
[3]: https://github.com/davidbudzynski/R-project-bootstrap
[4]: https://drivendata.github.io/cookiecutter-data-science/
[5]: https://github.com/fastverse/collapse
[6]: https://github.com/fastverse/kit
[7]: https://github.com/Rdatatable/data.table
[8]: https://rstudio.github.io/renv/
[9]: {% post_url 2024-11-20-docker-for-R %}
[10]: {% post_url 2026-09-01-renv-vs-docker %}
[11]: {% post_url 2024-04-20-why-r-is-a-terrible-language %}
