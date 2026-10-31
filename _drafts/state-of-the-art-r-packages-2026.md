---
layout : post
title  : "State of the art R packages in 2026"
tags   : [R, Data Science, Tooling]
description: "R's tooling never caught up with Python's, and agentic coding may finish the job — but the packages worth installing in 2026 are genuinely good."
---

Every year someone publishes a "state of the art Python packages" list. I read
it, nod at uv and ruff and Polars, and then open an R session anyway. This is
the R version. One caveat before the list: R's tooling has not kept pace with
Python's over the last few years, and the lists that pretend otherwise are the
reason nobody trusts them.

<!--more-->

## Let's be honest about the gap

In 2019 I would have argued that R had the better data toolkit. The tidyverse
was coherent, data.table was unmatched for speed, RStudio was the best IDE for
statistics, and Python notebooks were still a mess of hidden state. Then Python
shipped [uv][1], [ruff][2], [ty][3], [Polars][4], [marimo][5], and a
free-threaded interpreter, and the centre of gravity moved. R's answers arrived
later, often as bindings, ports, or one-person projects.

The reasons are structural, not mysterious. R has a smaller maintainer pool,
CRAN's release process is conservative by design, Posit's commercial priorities
are not the same as the language's, and the community values stability over
novelty. Python has venture-funded tooling companies; R has volunteers and a
handful of small teams. Pretending those are the same conditions is how you end
up with listicles that recommend a package last updated in 2017.

The gap is still there, but it narrowed in the places I care about. [Air][6] and
[Jarl][7] gave R a formatter and linter written in Rust; [pak][8] made installing
packages fast enough to stop thinking about it; [mirai][9] gave R real async;
and Polars finally has an R binding worth using. The gap didn't close because R
got faster at shipping. It narrowed because a few people shipped the right
things.

## The agent problem

There is a second gap opening, and it matters more than release cadence. Coding
agents write a growing share of new code, and they choose ecosystems by what
they can read, run, and edit. R's plain-text files are a natural fit. Its
policies are not always.

The clearest example is `data.table`, the package I would take to a desert
island. Its repository ships an [`AGENTS.md`][10] that tells coding agents, in
capital letters, to **stop and report** if they are asked to write package code.
The reasoning is licensing: the maintainers cannot verify the provenance of
model output, so they would rather not receive it. Fair enough as a legal
position. As a strategy for the next five years, it is a slow leak. If the
fastest data tool in the language tells agents to go away, agents will use
dplyr, DuckDB, or Polars instead — and they will recommend those to the person
asking. R won't lose to Python on features. It could lose to irrelevance.

That is a longer argument for another post. For now: the packages below are what
I would install in a fresh project today, in the order I reach for them.

## Setup: the part that changed most

Start with [rig][11], which installs and switches between R versions without
touching your system R. Then [pak][8], which installs packages from CRAN, Posit
Package Manager, GitHub, or a URL in parallel, uses binary packages on Linux,
and has become the default way I install anything.

For project reproducibility, [renv][12] still owns the lockfile. Every project
gets its own library and a `renv.lock` that records exact versions. If you have
not read my [renv vs Docker][13] post: renv pins the packages, Docker pins the
machine, and most projects only need the first.

Then the two tools that make the rest of this list feel modern:

- [Air][6] is a formatter and language server for R, written in Rust. Format on
  save in Positron, RStudio, VS Code, Zed, Neovim, or Emacs, or run
  `air format .` from the terminal. `air format --check .` is a one-line CI
  gate, and it finishes before you notice.
- [Jarl][7] is a linter in the same spirit: a single binary, no R installation
  required, `jarl check . --fix` to fix what it can. It has fewer rules than
  [lintr][14] and is much faster; I run Jarl on every save and keep lintr
  around for the rules Jarl does not cover yet.

Both are agent-friendly in a way that matters: fast, deterministic, and
runnable outside R. An agent can format and lint its own output before handing
it back. That is worth more than another DSL.

## Data

[data.table][15] is still the workhorse. Version 1.18 is fast, stable, and does
things no tidyverse package does without a copy. If your data fits in memory and
your group-by is heavy, this is the answer.

[collapse][16] is the package more people should know. It does fast grouped
aggregation, transformation, and reshaping with a syntax close enough to dplyr
that the switch is an afternoon, and it is often faster than data.table on
summaries. For big data, it is the first thing I try after data.table.

[dplyr][17], [tidyr][18], and [janitor][19] remain the readable option. Not
every script needs to be fast; most need to be understood six months later. I
use dplyr for anything under a few million rows and stop apologising for it.

For data that does not fit in memory, [DuckDB][20] is the least-effort win.
Point it at CSV or Parquet files, write SQL, get a data frame back. It also
speaks dbplyr, so existing dplyr code can run against it with minimal changes.
[Arrow][21] handles Parquet and Arrow IPC, and passes data to DuckDB without
copying.

[Polars for R][22] is the newest serious option: Rust bindings, lazy queries,
multi-threaded by default, installable from R-multiverse. If you already write
Polars in Python, the API is deliberately close. If you prefer tidyverse syntax,
[tidypolars][23] puts dplyr verbs on top of the same engine.

Finally, [qs2][24] for serialization. Saving and reading a large data frame is
noticeably faster than `saveRDS()`, which matters when a pipeline writes
intermediate artifacts.

## Modelling

[mlr3][26] is what I reach for personally. It has deeper support for
benchmarking, pipelines, task abstraction, and unusual resampling schemes, plus
extension packages for survival, clustering, and deep learning. If you want to
compare a dozen learners across a dozen resampling schemes without writing glue
code, this is the framework.

[tidymodels][25] is the better teaching toolkit: one grammar for preprocessing,
resampling, tuning, and evaluation. A `workflow()` bundles a model and a
`recipe()`, `tune_grid()` searches hyperparameters, and the whole thing reads the
same whether you are fitting a linear model or a boosted tree. My rule: mlr3 for
my own work, tidymodels when I am teaching or handing a project to someone who
wants one grammar.

For inference rather than prediction, [fixest][27] is the one. Fixed effects,
DiD, IV, and clustered standard errors, fast enough to run a specification
curve before lunch. Pair it with [modelsummary][28] for tables and
[marginaleffects][29] for average slopes and comparisons; together they cover
most of what applied economists used to do with three packages and a lot of
copy-paste.

For Bayesian work, [brms][30] with [cmdstanr][31] is still the most pleasant
way to write a model down and get posterior draws. It is not fast on big data,
and it is not meant to be.

## Pipelines and parallelism

[targets][32] is the pipeline tool I recommend without reservation. Declare
targets, declare dependencies, run `tar_make()`, and it skips everything that
has not changed. `tar_outdated()` tells you what will rerun before it does.
[tarchetypes][33] adds the shorthand for common patterns.

[crew][34] gives targets a controller for local or remote workers, and
[mirai][9] is the async primitive underneath a lot of modern R parallelism:
lightweight, fast, and much less ceremony than the future ecosystem. If you
still have `future.apply` calls, they are fine; new code should start with
mirai.

[pointblank][35] is the one people skip and later regret. It validates data at
the boundary — row counts, column types, value ranges, uniqueness — and fails
the pipeline before bad data reaches the model. In a world where half the bugs
are data bugs, this is cheaper than debugging downstream.

## Reporting

[Quarto][36] is the default for anything a human will read. One `.qmd` source,
HTML or PDF or Word out, parameters for reruns, and no notebook JSON in git. I
wrote about [why it beat Jupyter for me][37] already.

For tables, [gt][38] for HTML, [tinytable][39] for model output across formats,
and [flextable][40] when the destination is Word. For figures,
[patchwork][41] for composing multiple plots into one, which sounds trivial
until you have tried to align axes by hand.

## APIs and apps

[plumber2][42] is the new generation of R APIs: annotate functions, serve them
over HTTP, with async support and a cleaner lifecycle than the original
plumber. It is still young, so I would not bet a bank on it, but it is the
direction.

[httr2][43] is the client side: a request pipeline with retries, auth, and
sensible defaults. If you are still using `httr`, the migration is mostly
mechanical and worth it.

For Shiny, [bslib][44] for Bootstrap 5 theming and layout,
[shinytest2][45] for tests that actually click through the app, and
[shinylive][46] plus [webR][47] when you want a demo that runs entirely in the
browser with no server. Shiny is still the pragmatic choice for internal tools;
do not rewrite it in React because the internet told you to.

## What I would skip

- **rmarkdown** for new reports. Quarto does the same job with fewer sharp
  edges.
- **reshape2 and plyr**. tidyr and dplyr replaced them a decade ago.
- **styler** for formatting. Air is faster and does not need R running.
- **lintr as the only linter**. Keep it for its rules, but let Jarl do the
  first pass.
- **future.apply for new code**. mirai is lighter unless you need the future
  API for compatibility.
- **The data.table vs dplyr war**. Use both. The correct answer is whichever
  makes the next reader fastest.

## Install it

```r
install.packages("pak")

pak::pak(c(
  "renv",
  "data.table", "collapse", "dplyr", "tidyr", "janitor",
  "duckdb", "arrow", "qs2",
  "tidymodels", "mlr3", "fixest", "modelsummary", "marginaleffects", "brms",
  "targets", "tarchetypes", "crew", "mirai", "pointblank",
  "gt", "tinytable", "flextable", "patchwork",
  "plumber2", "httr2", "bslib", "shinytest2"
))

# brms needs a Stan backend; cmdstanr lives outside CRAN:
# install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))

# Polars and tidypolars live outside CRAN; install them from R-multiverse
# and Etienne Bacher's r-universe.
Sys.setenv(NOT_CRAN = "true")
install.packages("polars", repos = "https://community.r-multiverse.org")
install.packages("tidypolars", repos = c(
  "https://etiennebacher.r-universe.dev", "https://cloud.r-project.org"
))
```

Install [rig][11], [Air][6], and [Jarl][7] separately; they are binaries, not R
packages, which is exactly why they are fast.

## Closing

The state of the art in R is not a single package. It is that the good parts are
now fast, boring, and plain text: a formatter that runs before you blink, a
linter you can put in CI, an install that does not take a coffee break, a
pipeline that knows what changed, and a report format that survives a diff.

R will not win a tooling race against Python, and it does not need to. It needs
to stay good enough that the next analysis, the next paper, and the next agent
still reach for it. That is a lower bar than the listicles imply, and this year
R clears it.

[1]: https://docs.astral.sh/uv/
[2]: https://docs.astral.sh/ruff/
[3]: https://docs.astral.sh/ty/
[4]: https://pola.rs/
[5]: https://marimo.io/
[6]: https://posit-dev.github.io/air/
[7]: https://jarl.etiennebacher.com/
[8]: https://pak.r-lib.org/
[9]: https://mirai.r-lib.org/
[10]: https://github.com/Rdatatable/data.table/blob/master/AGENTS.md
[11]: https://rig.r-lib.org/
[12]: https://rstudio.github.io/renv/
[13]: https://davidbudzynski.github.io/2026/09/01/renv-vs-docker.html
[14]: https://lintr.r-lib.org/
[15]: https://r-datatable.com/
[16]: https://sebkrantz.github.io/collapse/
[17]: https://dplyr.tidyverse.org/
[18]: https://tidyr.tidyverse.org/
[19]: https://sfirke.github.io/janitor/
[20]: https://duckdb.org/docs/stable/clients/r
[21]: https://arrow.apache.org/docs/r/
[22]: https://pola-rs.github.io/r-polars/
[23]: https://tidypolars.etiennebacher.com/
[24]: https://github.com/traversc/qs2
[25]: https://www.tidymodels.org/
[26]: https://mlr-org.com/
[27]: https://lrberge.github.io/fixest/
[28]: https://modelsummary.com/
[29]: https://marginaleffects.com/
[30]: https://paul-buerkner.github.io/brms/
[31]: https://mc-stan.org/cmdstanr/
[32]: https://books.ropensci.org/targets/
[33]: https://docs.ropensci.org/tarchetypes/
[34]: https://wlandau.github.io/crew/
[35]: https://posit-dev.github.io/pointblank/
[36]: https://quarto.org/
[37]: https://davidbudzynski.github.io/2026/09/08/quarto-vs-jupyter.html
[38]: https://gt.rstudio.com/
[39]: https://vincentarelbundock.github.io/tinytable/
[40]: https://ardata-fr.github.io/flextable-book/
[41]: https://patchwork.data-imaginist.com/
[42]: https://plumber2.posit.co/
[43]: https://httr2.r-lib.org/
[44]: https://rstudio.github.io/bslib/
[45]: https://rstudio.github.io/shinytest2/
[46]: https://posit-dev.github.io/r-shinylive/
[47]: https://docs.r-wasm.org/webr/latest/
