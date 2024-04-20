---
layout : post
title  : "R is a Terrible Programming Language"
date   : 2024-02-21 19:00
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
interesing design choices like keeping function names inconsistent. For example,
some functions use underscores, some use dots, some use camel case, some use
Pascal case. For example there is `read.csv()` to read a CSV file, but if you want
to read the binary version of the object with the `.Rds` extension, you need to
use `readRDS()`.

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

### Backward compatibility with S

Although R is at version 4, it never had a major split like Python 2 and Python
3 did. As a result of this, there are many features built into the language that
maintain feature consistency with language called S, a proprietary language from
Bell Labs, which R is based on. In my opinion, S was far from a perfect language
and it definitely wasn't the best thing that came from Bell Labs. Because some
of these features are still in R, it makes the language very hard to use and
they make little sense to people in 2024. There even was a [meme account][10] on
Twitter that made fun of these features.

1. The user base has close to 0 knowledge about SWE, good coding practices and
   using version control best example of this is several OOP packages, with no
   consensus which one should be used.
2. Despite CRAN having many packages, the majority of them are very poorly
   written and barely usable and not very well maintained
3. The entire ecosystem has been hijacked by one company:

     - and this company appears to be pivoting into Python (first by making R
       tools work better with R but it is likely they will abandon R altogether,
       they appear to be sponsoring Python focused packages and they probably see
       that they make the most money from putting Python into production through
       their tools so this works for them)
     - RStudio sucks and isn't a serious IDE
     - Other than individual voices stating that their packages suck there
       appears to be zero resistance against them (because basic user of R
       doesn't even understand what dependencies are)
4. It gives the academia ivory tower vibes (bunch of academics developing the
   core language, not interacting with outside users, users mainly also in
   academia, not interested in contributing, students forced to use the language
   also not inclined to get involved in helping developing the language).
5. Hard to find any help because packages contain stupid puns containing the
   letter R and the one letter name doesn't seem to help with searching for help
   on google.
6. The language lack many basic tools like good code formatting, linting, etc.

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
