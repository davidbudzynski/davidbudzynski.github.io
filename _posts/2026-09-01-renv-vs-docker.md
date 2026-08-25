---
layout : post
title  : "renv vs Docker: when to use each"
date   : 2026-09-01 10:00
tags   : [R, Docker, Reproducibility]
---

A while back I wrote about [Docker for R projects][5], and the most common
reaction I hear sounds like this: "But I already use [renv][1]. Isn't that
enough?" It is a fair question, and the honest answer is: sometimes yes,
sometimes no. renv and Docker solve different halves of the reproducibility
problem, and knowing which half you need saves a lot of frustration. In this
post I want to compare the two tools directly and give some practical guidance
on when each is the right choice.

## What renv locks down

renv works at the **package level**. It gives every project its own private
library, and it records the exact state of that library in a lockfile called
`renv.lock`. A lockfile lists the R version plus every package the project uses,
with its version number and where it came from:

```json
{
  "R": {
    "Version": "4.4.2",
    "Repositories": [
      { "Name": "CRAN", "URL": "https://packagemanager.posit.co/cran/latest" }
    ]
  },
  "Packages": {
    "data.table": {
      "Package": "data.table",
      "Version": "1.15.4",
      "Source": "Repository",
      "Repository": "CRAN"
    }
  }
}
```

Anyone with your project and your lockfile can run `renv::restore()` and end up
with the same package versions you had. For most day-to-day breakage — an update
to a package changing behavior under you — renv solves the problem completely.
It is lightweight, fast to adopt, and stays out of your way. If you are not using
it yet, there is little excuse: it takes about five minutes to add to a project.

## Where renv stops

The catch is that renv only knows about R packages. It records which R version
you *had*, but it does not install or manage R itself. It knows nothing about:

- **System libraries** — GDAL, XML, ImageMagick, OpenSSL, LAPACK. Many R
  packages are thin wrappers around C/C++/Fortran libraries, and renv cannot pin
  those.
- **The operating system** — the same package version compiles against
  different system components on Ubuntu 22.04 versus macOS, and results can
  differ in subtle numerical ways.
- **CPU architecture** — an Apple Silicon Mac and an x86 Linux server are not
  the same machine, even with identical package versions.
- **Tooling outside R** — pandoc and LaTeX versions used to render reports, or
  Python if your project mixes languages.
- **Packages disappearing from CRAN** — a lockfile records versions, but it
  cannot conjure the tarballs back. If a package (or that exact version) is
  pulled from CRAN and you do not have it installed anywhere, `renv::restore()`
  fails on that package. The usual workarounds are pointing renv at
  [Posit Package Manager][3] date snapshots or the CRAN Archive, which keep old
  versions downloadable — or relying on renv's local cache, which only helps on
  machines where you happened to install the package before it vanished.

So renv answers the question "which packages?", but it leaves "which machine?"
unanswered — and even its answer to "which packages?" assumes CRAN still has
them.

## What Docker locks down

Docker works at the **environment level**. An image captures the operating
system, the system libraries, the R version, and everything else needed to run
your project. Combined with a dated [Posit Package Manager][3] snapshot — which
freezes CRAN as it looked on a given day — a single image pins every layer at
once:

```dockerfile
FROM rocker/r-ver:4.4.2

RUN Rscript -e "install.packages(c('data.table', 'ggplot2'))"

COPY analysis.R /project/analysis.R
CMD ["Rscript", "/project/analysis.R"]
```

Here `rocker/r-ver:4.4.2` pins Ubuntu and R, the package repository URL points
at a dated P3M snapshot so installed packages never move, and the image itself
pins the result. Rebuild it in five years and you get the same environment back.
This is what people mean by "it runs the same everywhere".

## When renv is enough

renv is the right tool, and Docker is overkill, when most of these are true:

- You work mostly alone, or your collaborators are on broadly similar machines.
- Your dependencies live in R packages without exotic system requirements.
- The deliverable is code, figures, or a report — not a running service.
- You value fast iteration: installing renv libraries is much quicker than
  rebuilding Docker images.

Most solo analyses, thesis projects, and internal reports fall into this
category. Do not let anyone tell you that you need Docker to be
"reproducible enough".

## When you want Docker

Reach for Docker when any of these apply:

- Your project depends on system libraries whose versions matter (spatial data
  is the classic offender).
- You are handing the project to someone else — a different team, an IT
  department, your future self on a new laptop.
- The deliverable runs somewhere: a Shiny app, a plumber API, a scheduled job
  on a server, a step in a CI pipeline.
- The result must still work years from now — think journal peer review or
  regulatory submissions.
- Your team mixes operating systems and "works on my machine" has become a
  standing joke.

## The best answer is usually both

The two tools are not rivals; they cover different layers and stack neatly.
My preferred setup for serious projects looks like this:

1. Track package versions with renv during development, so day-to-day work
   stays fast.
2. Bake the final environment into a Docker image based on a versioned
   [Rocker][2] image, restoring packages inside the container from
   `renv.lock`.
3. Run tests or render reports from that image in CI, so the lockfile and the
   image can never drift apart silently.

Bruno Rodrigues demonstrates exactly this pattern in his free book,
[Reproducible Analytical Pipelines with R][4], and I use a small variation of it
in my own [project bootstrap template][6].

## Closing thoughts

Use renv when you need to stop packages from moving under your feet. Use Docker
when the machine itself is part of the problem. And when a project really
matters — shared, deployed, or archived — use both: renv.lock for the package
layer, Docker for everything underneath it. Neither tool is complicated on its
own; together they make "it worked yesterday" a property of your project instead
of an accident.

[1]: https://rstudio.github.io/renv/
[2]: https://www.rocker-project.org/
[3]: https://packagemanager.posit.co/
[4]: https://raps-with-r.dev/
[5]: https://davidbudzynski.github.io/2024/11/20/docker-for-R.html
[6]: https://github.com/davidbudzynski/R-project-bootstrap
