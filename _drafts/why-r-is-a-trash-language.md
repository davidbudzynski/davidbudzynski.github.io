---
layout : post
title  : "R is a Terrible Programming Language"
date   : 2024-04-20 13:05
tags   : [R, Software, Data Science] 
---

Recently I have been contemplating about how I feel about R as a programming
language. Even though I have been using it for many years now, I have never been
able to shake the feeling that apart from several nice packages, R is an
inferior language.

Over the years there have been many criticisms of R, some of them are valid,
like the [R Inferno book][1], some of them are not, like many medium articles by
freshman year data science students who just discovered Python and R. More
recently I read a [blog post][2], where the author echoes many of my own views
about R, so I thought I would write my own take on the subject and give reasons
why I want to rely less and less on R in the future.

## What R does well

Before I start bashing R, I want to mention that not everything about R is bad.
There are some things that are hard to find a match for in other languages.

### small exploratory analyses

When it comes to small exploratory analyses, R is hard to beat. It is very easy
to load data, clean it, and do some basic analyses. This is especially true when
the data is in a CSV file, which is the most common format for data in the wild.
You don't really need any external libraries to do this, the base R is enough.
It is easy to execute the code in the REPL, and you can quickly see the results,
like in this example:

```R
# Load the dataset (assuming it's in a CSV file named 'student_data.csv')
data <- read.csv("student_data.csv")

# Check for missing values
missing_values <- any(is.na(data))
if (missing_values) {
   print("There are missing values in the dataset.")
   # Handling missing values - for simplicity, we'll just remove rows with
   # missing values
   data <- na.omit(data)
}

# Detect and handle outliers (assuming Test_Score and Study_Hours are numeric
# variables)
outliers <- boxplot.stats(data$Test_Score)$out
if (length(outliers) > 0) {
   print("Outliers detected in Test_Score. Removing outliers.")
   data <- data[!data$Test_Score %in% outliers, ]
}

# Aggregation: Calculate average test score by pass/fail status
aggregate(Test_Score ~ Pass_Fail, data = data, FUN = mean)

# Aggregation: Calculate median study hours by pass/fail status
aggregate(Study_Hours ~ Pass_Fail, data = data, FUN = median)

# Aggregation: Count the number of students in each pass/fail category
table(data$Pass_Fail)

# Aggregation: Summarize test scores by quartiles
quantile(data$Test_Score, probs = c(0, 0.25, 0.5, 0.75, 1))

# Aggregation: Calculate summary statistics by pass/fail status
aggregate(
   cbind(Test_Score, Study_Hours) ~ Pass_Fail,
   data = data,
   FUN = function(x) c(mean = mean(x), sd = sd(x), min = min(x), max = max(x))
)
```
When you are working on these small analyses it is quite easy to use external
packages by just installing them from CRAN with `install.packages("package")`.

If you want to do more complex analyses on top of descriptive statistics, it is
also very trivial to run a linear regression or a logistic regression.

```R
# Generate some example data
set.seed(123)
x <- 1:100
y <- 2 * x + rnorm(100, mean = 0, sd = 10)

# Fit linear regression model
linear_model <- lm(y ~ x)

# Summary of the linear regression model
summary(linear_model)

# Plot the data and the regression line
plot(x, y, main = "Linear Regression Example", xlab = "x", ylab = "y")
abline(linear_model, col = "red")
```

```R
# Generate binary outcome data
set.seed(123)
x <- rnorm(100)
prob <- exp(0.5 + 2 * x) / (1 + exp(0.5 + 2 * x))
y <- rbinom(100, size = 1, prob)

# Fit logistic regression model
logistic_model <- glm(y ~ x, family = binomial)

# Summary of the logistic regression model
summary(logistic_model)

# Plot the data and the logistic regression curve
plot(x, y, main = "Logistic Regression Example", xlab = "x", ylab = "y", col = ifelse(y == 1, "blue", "red"))
curve(predict(logistic_model, data.frame(x = x), type = "response"), add = TRUE, col = "green")
```

If you want to send this code to someone else, you can easily put the data into
a [quarto][3] document and render the code into a PDF or HTML report. It is very
similar to [Juptyer notebooks][4] in Python, but I find it easier to use and
quarto's predecessor, [RMarkdown][5], pioneered this concept within the data
science community. I am aware that quarto is not as popular as Jupyter notebooks
are and that it also supports Python, but both quarto and Rmarkdown have more
mature ecosystems that Jupyter notebooks and are text based, so they are easier
to version control.

### Plotting

As you saw in examples above, R comes with a plotting library built in. While
that library is not the best and it isn't very flexible and powerful, the
[ggplot2][6] package is. This package is regarded as the best plotting library
in the entire data science community. It is very easy to use and it is very
powerful. It is also very easy to customize the plots, so you can make them look
exactly how you want them to look. There are many people who claim that R is
worth learning just so you can use ggplot2. On top of the package, there are
dozens of extensions that make it even more powerful.

### Niche packages

There are many packages that are very good and that are not available in other
languages. For example, the [data.table][7] package is one of the fastest data
manipulation packages in the world. It is very easy to use and it is very
powerful. It is also very easy to use it in parallel, so you can speed up your
code by using all the cores on your machine. The package is also very well
maintained and it is very popular. The package is so good that it is used by
many other packages as a backend because it is so fast and does not have any
dependencies. Python has been catching up with R in terms of data manipulation
with packages like [polars][8] but it is still not as well established as
data.table is.

In addition to very good quality packages, there are also many packages that are
very niche and although they are not very popular, they are very useful for some
people/companies. For example, there are many packages that are used for
Bayesian modelling through the [rstan][9] package. Many academics select R to
create a package that uses a novel method they developed, so there are many
packages that are not available in other languages.

## What makes it difficult to use R

### For Statisticians by Statisticians

One of the major problems with R is that it was designed by statisticians for
statisticians. This means that it is very good at doing statistics, but it is
not good at being a programming language. The language makers chose some very
interesting design choices like keeping function names inconsistent. For
example, some functions use underscores, some use dots, some use camel case,
some use Pascal case. For example there is `read.csv()` to read a CSV file, but
if you want to read the binary version of the object with the `.Rds` extension,
you need to use `readRDS()`.

Another example is the `apply()` function. It is a very powerful function that
allows for functional programming in R, but it is very hard to use. It is very
hard to remember the arguments of the function, so you need to look them up
every time you want to use it. This is a very common problem in R, many
functions are very hard to use because they have many arguments and they are not
consistent with each other. For this reason, people say not to use `apply()` and
use `lapply()`, `sapply()`, `vapply()`, `mapply()`, `tapply()`, `rapply()`,
depending on what you want to achieve, or you can use a 3rd party package called
`purrr` which is a wrapper around these functions and makes them easier to use.
Crazy right?

R developers appear to be a fairly small group of people who are not very open
to the work that they do or new ideas. The only reason to find what they are
working on is to follow the mailing list, which for many younger developers is
an archaic way of communication. This makes it very hard to get involved in the
core community. Many of those core contributors are also academics, so the whole
process of getting involved in the community gives off ivory tower vibes.

### Backward compatibility with S

Although R is at version 4, it never had a major split like Python 2 and Python
3 did. As a result of this, there are many features built into the language that
maintain feature consistency with language called S, a proprietary language from
Bell Labs, which R is based on. In my opinion, S was far from a perfect language
and it definitely wasn't the best thing that came from Bell Labs. Because some
of these features are still in R, it makes the language very hard to use and
they make little sense to people in 2024. There even was a [meme account][10] on
Twitter that made fun of these features.

### R users are not software engineers

Something also has to be said about the target audience, average users of R.
Many institutions and companies use R because it is free and gets the job done.
What I mean by that is that it is either used as a tool that teaches you to
implement and use statistics or it is used as a tool that allows you to leverage
statistics to achieve something you want. In both cases, the user base has close
to zero knowledge about software engineering, good coding practices and using
version control. Many R users are not even aware that there are tools that can
help them write better code, like linters, formatters, etc. This is why many R
packages are very poorly written and barely usable and not very well maintained.
That is why there are many [threads on StackOverflow][11] that ask for help with
Rstudio instead of R, and often do not even know the difference between the two.
Same goes for git and GitHub, it is shocking how long it took me to explain the
differences between the two to my colleagues at work and they still get it wrong
when speaking to Software Engineers. 

I think that the greatest example showing bad language design and a subpar user
base is the implementation of object oriented programming (OOP) in R. There is a
base class called `S3` that is very easy to use, but it is very hard to write
good code with it. There is also a base class called `S4` that is very hard to
use, but it is very easy to write good code with it. To make things worse, there
are several 3rd party packages that implement OOP in R, like `R6`, and
even they can't get it right because Posit's `R6` is going to be abandoned in
favor of Posit's `R7`. When I say abandoned, I don't mean that it won't be
supported at all but with small usage base and limited resources you can't
expect that it will be maintained as well as it should be.

No consensus on which OOP package should be used makes it hard to write good
large scale code in R. When you contrast this with Python, there is only
one way to do OOP.

### Poor quality development tools

One of the most important tools for a software developer is the search engine.
When you are stuck on a problem, you can just google it and you will find the
answer if your searching skills are good enough. This is often not the case with
R. The reason behind is that the language is called R, so you get a lot of false
results or references to Reddit, because each community there starts with `r/`.
This is a small gripe, but it is a very annoying one, and I would say it is a
large obstacle for beginners, judging from the number of times junior
statisticians came to me asking questions that could be done with a little bit
of searching on Google.

The second most important tool for a software developer is the IDE. RStudio is
the most widely used one for R and it is shockingly bad. It is very slow, has
limited support for 3rd party plugins, it uses a fair amount of memory. *It does
not support LSP*. Up until not too long ago it didn't have an option to store
settings in a file, so every time you wanted to use a new machine you had to set
up everything from scratch. Although it is open source, it is not very easy to
contribute to it, as the development is done by a company that also offers
closed source products build on top of the open source core.

To be completely fair, there are other IDEs that you can use for R but they
aren't much better or have different set of problems. For example, ESS is a
package for Emacs that is very powerful but it is very hard to use and it is not
very user friendly. The development cycle of the package moves at a snail pace
and there are many bugs that remain unfixed at the time of writing this post.
VScode is a very good IDE for many languages, but it is not very good for R.
(Neo)Vim is a very good text editor, but it is not very good for R.

The overall quality of the development tools for R is very poor, compared to
other languages like Python, C++, Java, etc. There is only one code formatter
that kind of works, but it doesn't cover all edge cases are is quite slow
because it was written in R itself, the LSP support in the most popular IDE is
nonexistent and so is tree sitter support. This makes it very hard to write good
code as a team because everyone is doing their own thing and you end up with the
code being written in many different styles, and if you remember what I wrote
about an average R user, you can imagine how bad the code can get.

### One company hijacking the ecosystem

If you rewind back to late 2000s and early 2010s, you will see that R was a very
tiny community. It was simpler times when statisticians did not call themselves
data scientists. A company called RStudio came along and made a very good IDE.
Along with it came several packages like ggplot2 that made R very popular. Those
prominent people in the community joined RStudio and they started making more
tools and packages for R. Over the course of years they created a lot of
packages and one meta-package the Tidyverse. Unfortunately, the IDE hasn't been
getting better and better and those many packages were dependent on each other
making everything bloated. Many new people who are new to R did not make a fuss
about that and many established R contributors did but because of slow paced
development of the base R, Tidyverse packages became insanely popular, creating
a schism between writing base R code and a Tidyverse-friendly equivalent (based
on piping the data from one function to another).

This is quite a unique position a language can find itself in. The standard way
defined by using the standard library gets rejected over a 3rd party solution
that is based on hundreds of many different dependencies. Many people do not
care about those when working on one-off analyses, but once you move to
production and want a stable environment, dealing with them becomes difficult to
manage.

In 2022 Rstudio rebranded themselves as Posit, giving reasons that they also
want to focus on Python as well as R, and the old name was confusing. Many
people were concerned that this probably means that they will want to pivot
themselves from R to Python as this is the language of data science now. They
obviously denied it it needs to be said that their departure from R to Python
can be seen in the number of latest RStudio IDE releases and R package releases.
On top of it, they layed off the creator or RMarkdown after trying to move
people to Quarto, which is a more language agnostic platform leveraging similar
technologies.

It appears that they want to diminish their activity within the open-source R
community and focus more on Python in production because this is where the money
is. This is quite transparent when you look where their promotion and funding
goes to. They sponsor Python related podcasts like Talk Python to Me, but I
can't say that they do the same with the only R related podcasts which is R
Weekly Highlights. It remains to be seen where they end up being in a couple of
years but my impression is that they will stay engaged with R but to a much
lesser extent.

### Poor quality packages

Despite R having many packages, the majority of them are very poorly written and
barely usable and not very well maintained. This is because many R users are not
software engineers and they do not know how to write good code. Another annoying
thing is that many packages contain stupid puns containing the letter R in it.
Searching for such packages is very hard because they often don't explain what
they actually do and are hard to discover. Think about `dplyr` or `purrr`. Would
you know what they do if you didn't know them already?

### Outdated packaging system

CRAN is the official package repository for R. At the time of its creation, it
was a very good idea, but it has not aged well. The process of submitting a
package is very tedious and it takes a long time. Same goes for maintenance of
those packages. Sometimes CRAN maintainers will ask you to make changes to your
package because they made changes to their infrastructure and your package is
not compatible. On top of this, CRAN does not provide binaries on Linux, so you
need to compile them from source, which sometimes takes a lot of time and
resources. 

There are competing 3rd party package "marketplaces" like ROpenSci, Posit
Package Manager, GitHub. They are much easier to use and they are much faster
than CRAN when it comes to submitting a package. Some of them even provide Linux
binaries, so they are a good alternative to CRAN.

All of these package managers have the same problem which is inherent to R. It
is impossible to ensure reproducibility without resorting to half baked 3rd
party packages like `renv` and/or `groundhog` and even they can't guarantee it.
Because of this, the only way to ensure reproducibility is to use Docker images.
This is also a problem with Python as well, but people using Python don't have
issues with it because they are more likely to be software engineers and they
know how to write good code. On the other hand, an average R user haven't heard
about Docker.

## Alternatives to R

So with all of these issues that I mentioned earlier, what are the alternatives?
Well, there is no perfect solution to this problem. The de facto language for
data science is Python, but it has its own set of problems. It is much more
versatile and has a much larger user base, so it is much easier to find help and
resources. It is much easier to write good code in Python. Many LLMs are
implemented in Python, so if you want to use them, you need to use Python. Even
though Python is not as good as R for statistics, it is good enough for most use
cases. Python is quite fast, thanks to C and C++ libraries and more recently
Rust. If you want to write tools for Python or you are interested in HPC and
machine learning in general, C++ is still king. Python and C++ compliment each
other very well, so you can use Python for data manipulation and C++ for heavy
lifting.

## Conclusions

If you are planning to learn R, I would advise against it. There are not many
reasons to learn R if you want to be a data scientist. Learn Python first and if
you feel like you need to use a package from R that is not available in Python,
you can use LLMs like chatGPT to write the code for you. Once you go deeper than
fiddling with spreadsheets and databases and need true speed, low memory usage
as well as good type safety, you can learn C++. The combination of Python and
C++ is the best of both worlds and it is much better than R. C++ is a difficult
language to learn but one you get over that hurdle and write some code in it,
you will have much deeper understanding of how computers work and how to write
good code. Python on the other hand is very easy and it will allow you to
abstract these low level details and focus on the problem you are trying to
solve.

[1]: https://www.burns-stat.com/pages/Tutor/R_inferno.pdf
[2]: https://www.hendrik-erz.de/post/a-rant
[3]: https://quarto.org/
[4]: https://jupyter.org/
[5]: https://rmarkdown.rstudio.com/
[6]: https://ggplot2.tidyverse.org/
[7]: https://rdatatable.gitlab.io/data.table/
[8]: https://polars.rs/
[9]: https://mc-stan.org/rstan/
[10]: https://twitter.com/WhyDoesR
[11]:https://stackoverflow.com/q/63606106/13158146
