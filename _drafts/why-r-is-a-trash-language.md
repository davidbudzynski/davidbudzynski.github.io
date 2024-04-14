---
layout : post
title  : "R is a Terrible Programming Language"
date   : 2024-02-21 19:00
---

Into text here. say it was in your head but writing it prompted by a similar
article liked here: https://www.hendrik-erz.de/post/a-rant

## What R does well

### small exploratory analyses

something that won't be used by others, or does not matter that it dependencies
will be outdated in 2 years

quick prototyping on datasets coming from CSV files

in relation to the previous point: calculating descriptive stats and stat
modelling like linear regression

### plotting

ggplot works well and is usually quite intuitive

### Niche packages

this is both good and bad, for several years there weren't that many packages to
compete with `data.table` in terms of functionality and speed but python caught
up and surpassed it with the `polars` package.

## What makes it diffiult to use R

### For Statisticians by Statisticians (this needs to broken into smaller points as there is a lot to unpack)

1. There are many bizzare language design decisions, like inconsistent fucntion
   names.
2. this meme account showing compatibility with a proprietary language used by
   nobody: https://twitter.com/WhyDoesR
3. The user base has close to 0 knowledge about SWE, good coding practices and
   using version control best example of this is several OOP packages, with no
   consensus which one should be used.
4. Despite CRAN having many packages, the majority of them are very poorly
   written and barely usable and not very well maintained
5. The entire ecosystem has been hijacked by one company:
   
     - and this company appears to be pivoting into Python (first by making R
       tools work better with R but it is likely they will abandon R altogether,
       they appear to be sponsoring Python focused packages and they probably see
       that they make the most money from putting Python into production through
       their tools so this works for them)
     - RStudio sucks and isn't a serious IDE
     - Other than individual voices stating that their packages suck there
       appears to be zero resistance against them (because basic user of R
       doesn't even understand what dependencies are)
6. It gives the academia ivory tower vibes (bunch of academics developing the
   core language, not interacting with outside users, users mainly also in
   academia, not interested in contributing, students forced to use the language
   also not inclined to get involved in helping developing the language).
7. Hard to find any help because packages contain stupid puns containing the
   letter R and the one letter name doesn't seem to help with searching for help
   on google.
8. The language lack many basic tools like good code formatting, linting, etc.

### Outdated packaging system

1. CRAN does not provide binaries on Linux, so you need to compile everything
   from source
2. the entire process of submitting a package undergoes a human review, your
   package needs to compile on some v old architectures like Solaris
3. There are competing 3rd party package "marketplaces": ROpenSci, Posit Package
   Manager, GitHub
4. It is impossible to ensure reproducibility without resorting to half baked
   3rd party packages (renv, groundhog) and even they can't guarantee it, so you
   need to use Docker

### Alternatives

Python and C++
