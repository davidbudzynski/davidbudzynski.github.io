---
layout : post
title  : "Quarto for reproducible reports vs Jupyter"
date   : 2026-09-08 10:00
tags   : [Quarto, Jupyter, Reproducibility, Data Science]
---

Some time ago I wrote about running [C++ notebooks in Emacs' Org mode][3]. The
specific tool did not matter that much — the point I was circling around is that
plain text is a great medium for mixing code, results, and prose. In this post I
want to apply that same argument to everyday data science work and compare
[Jupyter][2] notebooks with [Quarto][1] documents for anything that deserves to
be called a *report*.

## The notebook problem

I like Jupyter. For poking at an unfamiliar dataset it is hard to beat: run a
cell, see a plot, adjust, run again. But the moment a notebook becomes a
deliverable — something another person has to read, review, or rerun — its
weaknesses show up quickly:

- **Hidden state.** Cells are executed in whatever order you happened to run
  them. The notebook on screen does not match any actual run of the code.
  Variables left over from deleted cells silently shape your results.
- **It lies when rerun.** Restart the kernel and execute top to bottom — the
  honest test — and half of the notebooks I have received fail or produce
  different numbers.
- **Terrible diffs.** An `.ipynb` file is JSON with outputs embedded in it,
  including plots as base64 blobs. Change one line of code and git reports a
  thousand-line diff. Merge conflicts in notebooks are practically unresolvable.
- **Painful review.** Reviewing a notebook means trusting the stored outputs,
  because there is no cheap way to verify they were produced by the code shown.

None of this matters for scratch work. All of it matters when the notebook *is*
the result.

## What Quarto does differently

A Quarto document is just Markdown with code chunks:

````markdown
---
title: "Churn analysis"
format: html
execute:
  echo: false
---

## Monthly churn

```{python}
#| label: churn-by-cohort
churn.groupby("cohort")["churned"].mean().plot(kind="bar")
```
````

You render the document, Quarto executes every chunk **in a fresh session, from
top to bottom**, and weaves the results into the final output. That single
design decision fixes most of the problems above:

- There is no hidden state, because each render starts from nothing. If the
  document rendered, then the code in it runs — by construction.
- Diffs are clean. A `.qmd` file contains only source: your text and your code.
  Outputs are regenerated, not stored, so git shows you exactly what changed.
- One source, many formats: HTML, PDF, Word, slides. The `format` key is all
  that changes.

This is the same idea Org mode has had for years, and the same idea behind
literate programming going back decades: keep the source in plain text, treat
the output as a build artifact. Quarto did not appear out of nowhere, either —
it is the successor to [R Markdown][4], built by the same team on top of
[Pandoc][5] and the knitr engine, and generalized beyond R. If you have old
`.Rmd` reports lying around, moving them over is mostly a matter of renaming
and tidying the YAML header.

## It is not either/or

Here is the part that surprises people: Quarto is not tied to R. Its execution
engine can be Jupyter itself, so you can keep writing Python with an ipykernel
underneath and still get all the benefits above. You do not have to abandon the
Python ecosystem to stop shipping `.ipynb` files.

The boundary is porous in the other direction too. `quarto convert` turns a
`.qmd` document into a Jupyter notebook (and back), and if even notebooks feel
too heavy, Quarto will render a plain Python or R script as a document: cells
are marked with ordinary comments, prose lives in block comments, and the file
still runs as normal code. So you are never locked into a special format — the
document can always be turned back into pure code with comments.

The tools also answer different needs. Keep Jupyter (or a REPL) for
exploration — the messy loop where you are not sure what you are looking for
yet. But the moment you know the story and need to tell it to someone else,
move the code into a Quarto document and render it. Exploration wants
interactivity; communication wants determinism.

## My rule of thumb

If a document will be read by anyone other than present me — a colleague, a
reviewer, future me next quarter — it should be a Quarto (or Org, or R Markdown)
document that renders from a clean state, committed as plain text, ideally
rendered automatically in CI so nobody can forget. Notebooks remain my sketchpad;
they are just not the thing I hand over at the end.

[1]: https://quarto.org/
[2]: https://jupyter.org/
[3]: https://davidbudzynski.github.io/2024/04/15/cpp-notebooks-org-mode.html
[4]: https://rmarkdown.rstudio.com/
[5]: https://pandoc.org/
