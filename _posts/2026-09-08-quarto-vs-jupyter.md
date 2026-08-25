---
layout : post
title  : "Why Jupyter notebooks have lost their advantage"
date   : 2026-09-08 10:00
tags   : [Jupyter, Quarto, Emacs, Reproducibility, AI]
---

Ten years ago, if you wanted code, results, and prose in one place, a
[Jupyter][1] notebook was essentially the only game in town. That monopoly is
over, and it did not end because notebooks got worse — it ended because every
tool around them caught up. Interactivity lives in editors and REPLs,
literate reports live in R Markdown and its successor Quarto, and Emacs' Org
mode was doing the whole thing before notebooks were cool. I used
[R Markdown][4] for years myself, and somewhere along the way I stopped seeing
what notebooks still offered. This post is my attempt to pin down why.

## The notebook problem

To be fair to [Jupyter][1]: for poking at an unfamiliar dataset, running a cell
and seeing a plot right there is a genuinely good loop. But the moment a
notebook becomes something another person has to read, review, or rerun, the
problems show up quickly:

- **Hidden state.** Cells run in whatever order you happened to execute them,
  so the notebook on screen does not correspond to any actual run of the code.
- **It lies when rerun.** Restart the kernel and execute top to bottom — the
  honest test — and many notebooks fail or produce different numbers.
- **Terrible diffs.** An `.ipynb` file is JSON with outputs embedded, plots
  included as base64 blobs. One changed line produces a thousand-line diff, and
  merge conflicts are practically unresolvable.

None of this matters for scratch work. All of it matters when the notebook *is*
the result. And crucially, the good part — interactivity with inline output —
no longer requires any of this baggage.

## The REPL never went away

For exploration, an [IPython][2] session does most of what a notebook does:
run a statement, look at the result, adjust, repeat. The trick that replaces
the rest is `python -i script.py` — it runs your whole script and drops you
into an interactive session with every variable still loaded, so you can poke
at the data without copying anything into cells. Add `breakpoint()` anywhere
and you get step-by-step inspection for free.

## Notebooks without `.ipynb` files

If you want cell-by-cell execution with inline output, you do not need the JSON
container anymore. The [Jupyter extension for VS Code][5] turns an ordinary
Python script into an interactive notebook using nothing but comments:

```python
# %%
import pandas as pd

df = pd.read_csv("data/raw.csv")
df.groupby("region")["amount"].sum()
```

Each `# %%` marks a cell. You send chunks to the Interactive Window, plots show
up next to the code, and the variable explorer works exactly like in a
notebook. The difference is that the file itself is still a normal script: you
can run it with `python analysis.py`, grep it, diff it, refactor it, and merge
it like any other code. Same interactive loop, none of the format tax.

## Org mode: tangling instead of containers

I wrote before about running [C++ notebooks in Org mode][3], and the tool
mattered there: Babel lets you execute code blocks inside a plain text file and
collect results inline. The killer feature for me is [tangling][6]: mark a
block with `:tangle analyze.py` and Org extracts all your code into a clean,
pure Python (or R) script. The document and the program are two views of the
same plain text file — at any moment you can produce a version with zero
markup, zero results, ready to run or hand over.

That is the exact opposite of the notebook philosophy. Instead of wrapping
code in a special container, Org keeps everything in text and derives whatever
artifact you need.

## Reports: R Markdown grew into Quarto

For deliverables, I was a long-time R Markdown user, and its lineage continues
in [Quarto][7]: built by the same team on top of [Pandoc][8] and knitr,
generalized beyond R. The model is unchanged and still the right one — a text
document with code chunks that executes **from a fresh session, top to bottom**,
so the output cannot lie about how it was made. Diffs stay readable because
outputs are regenerated rather than stored, and one source renders to HTML,
PDF, Word, or slides.

It also plays along with the rest of the toolbox: `quarto convert` moves a
`.qmd` document into a Jupyter notebook and back, and Quarto happily renders a
plain commented Python or R script as a document. Nothing locks you into a
special format.

## The part that settled it: agents

There is one more reason plain text won, and for me it is the decisive one:
AI coding agents work extremely well with these files and poorly with
notebooks. An agent can read a `.py`, `.qmd`, or `.org` file, understand it,
and edit it like any other source code. Point the same agent at an `.ipynb`
and it has to wade through megabytes of JSON and base64 output blobs, where one
careless edit corrupts the whole file. Plain text workflows are
*agent-accessible*, and these days I consider that one of the most important
properties a tool can have — my agent writes and refactors a large share of my
analysis code, and I am not giving that up to keep results inside a notebook.

Version control is what kept plain text formats alive through the notebook era.
Agents are what made them unbeatable.

## Closing thoughts

A decade ago the notebook was the only tool offering "code and output in one
place". Today that experience lives in the REPL, in editor cells over plain
scripts, in Org mode, and in Quarto documents — tools that version cleanly,
review cleanly, render reproducibly, and let an agent work alongside you. The
notebook no longer has a single advantage that justifies its costs. It had a
good run, but the plain text stack simply offers more.

[1]: https://jupyter.org/
[2]: https://ipython.org/
[3]: https://davidbudzynski.github.io/2024/04/15/cpp-notebooks-org-mode.html
[4]: https://rmarkdown.rstudio.com/
[5]: https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter
[6]: https://orgmode.org/manual/Extracting-Source-Code.html
[7]: https://quarto.org/
[8]: https://pandoc.org/
