---
layout : post
title  : "Writing Python for data work without Jupyter"
date   : 2026-09-15 10:00
tags   : [Python, Data Science]
---

When I moved most of my work from R to Python, everyone assumed I would live in
[Jupyter][1] notebooks. I tried, honestly. But after years of writing analyses
that run top to bottom — first in R scripts driven by Makefiles, later wrapped
in Docker — the notebook workflow never grew on me. The good news I want to
share in this post: you lose surprisingly little by doing data work in the
terminal, and you gain a lot in reproducibility and sanity when the project
grows.

## Exploration: the REPL is enough

The first thing people reach for in a notebook is interactivity: run something,
look at the result, adjust. A Python REPL does the same job without the JSON
baggage. [IPython][1] gives you tab completion, history, shell escapes, and the
familiar `%paste` / `%rerun` conveniences:

```bash
ipython
```

```python
In [1]: import pandas as pd

In [2]: df = pd.read_csv("data/raw.csv")

In [3]: df.groupby("region")["amount"].sum().sort_values()
```

The trick that makes the REPL genuinely replace a notebook is
`python -i script.py`. It runs your whole script and then drops you into an
interactive session with every variable still alive, so you can poke at `df`
afterwards without copying code into cells. Add `breakpoint()` anywhere in the
script and you get the same cell-by-cell feeling, except the execution order is
always honest: exactly what the file says, top to bottom.

## Real work lives in scripts anyway

A notebook is a place to think; a script is a thing you can rerun tomorrow. So
the moment an exploration turns into something I will run more than once, it
becomes a small script with a command-line interface. Nothing fancy — the
stdlib [argparse][5] module is plenty:

```python
# src/analyze.py
import argparse

import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("--data", default="data/raw.csv")
parser.add_argument("--out", default="output/summary.csv")
args = parser.parse_args()

df = pd.read_csv(args.data)
summary = df.groupby("region")["amount"].agg(["sum", "mean", "count"])
summary.to_csv(args.out)
print(summary)
```

A project ends up looking like this:

```
project/
├── Makefile
├── data/          # input, never edited by hand
├── output/        # generated, safe to delete
├── src/
│   ├── fetch.py
│   └── analyze.py
└── README.md
```

Two rules keep it tidy. First, everything in `output/` is disposable — if a
result matters, the *script* that produces it matters, not the artifact. Second,
scripts read from `data/` and write to `output/`, nothing in between. With those
rules, "can you rerun the analysis?" stops being a scary question.

## Makefiles hold it together

Individual scripts are fine, but real projects have steps: download, clean,
aggregate, plot. This is where a [Makefile][4] earns its keep. Each step is a
target, dependencies are declared once, and Make figures out what needs to
rerun:

```makefile
data/raw.csv:
	python src/fetch.py --out $@

output/summary.csv: data/raw.csv src/analyze.py
	python src/analyze.py --data $< --out $@

all: output/summary.csv

clean:
	rm -rf output
```

Now the whole pipeline is `make`. Changed only the analysis code? Make skips the
download and reruns the rest. Cloned the project on another machine?
`make all` builds everything from nothing. I use this exact pattern in my
[R project bootstrap template][3], and it translates to Python one to one. As a
bonus, this is also the shape CI systems expect, so wiring the same targets into
GitHub Actions later is trivial.

## Quick looks without opening anything

Half of what people use notebooks for is "just let me look at the data". The
terminal has answers that are faster than starting any server:

- [DuckDB][2] queries CSV and Parquet files directly, no import step:

  ```bash
  duckdb -c "SELECT region, sum(amount) AS total \
             FROM 'data/raw.csv' GROUP BY 1 ORDER BY total DESC"
  ```

- One-liners for a quick peek: `head -5 data/raw.csv | column -t -s,`,
  or `python -c "import pandas as pd; print(pd.read_csv('data/raw.csv').describe())"`.
- Plots go straight to files (`plt.savefig("output/plot.png")`), which sounds
  worse than inline images until you notice that files land in `output/`,
  get versioned with everything else, and can be embedded straight into a
  report.

That last point matters more than it seems. Once plots are artifacts instead of
cell outputs, they become inputs to the next stage — usually a rendered report,
which is where presentation belongs anyway.

## What I miss, honestly

To be fair to notebooks: sketching visualizations is nicer when the image
appears under the code. My workaround is to keep plotting code in the script and
re-render on save, but I will admit the feedback loop is slightly slower. For
pure exploration I still open a REPL; for anything that will be shown to another
human being, the script-plus-Makefile setup wins, because the thing I hand over
is exactly the thing I ran.

And that is the whole argument in one sentence: notebooks optimize for the
session you are in right now, while scripts, Makefiles, and a couple of CLI
tools optimize for every session after this one — including the one where
future you tries to remember what happened.

[1]: https://ipython.org/
[2]: https://duckdb.org/
[3]: https://github.com/davidbudzynski/R-project-bootstrap
[4]: https://www.gnu.org/software/make/
[5]: https://docs.python.org/3/library/argparse.html
