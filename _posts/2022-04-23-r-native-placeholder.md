---
layout: post
title: "R 4.2.0 Native Placeholder"
date:   2022-04-23 21:00
category: general
---

Yesterday (that is on April 22, 2022) R 4.2.0 was released and among
other things, this release brought major improvements when using the
native pipe operator (`|>`).

You might be wondering: what is the native pipe anyways? Well, it's the
base equivalent of `%>%` pipe from the `magrittr` package heavily
endorsed and used across `tidyverse` packages. It pipes a value forward
into an expression or function call. This practice is common in other
programming bd languages like F# or Elixir. Using pipes compared to
regular nesting of functions within each other allows for more readable
code, since each step is presented in chronological order. Nested
functions need to be read from the inside out to figure out what was the
fist function used. Consider this example:

``` r
library(tidyverse, warn.conflicts = FALSE)

slice(select(
  mutate(
    filter(mtcars, hp > 100), mpg = round(mpg)
  ),
  mpg, cyl, disp, hp
), 1:5)
```

``` r
                  mpg cyl disp  hp
Mazda RX4          21   6  160 110
Mazda RX4 Wag      21   6  160 110
Hornet 4 Drive     21   6  258 110
Hornet Sportabout  19   8  360 175
Valiant            18   6  225 105
```

By only using three functions it's not easy to find go from the inside
out to find out where you started and where are you going with functions
applied. Pipes make it much easier.

``` r
mtcars %>%
  filter(hp > 100) %>%
  mutate(mpg = round(mpg)) %>%
  select(mpg, cyl, disp, hp) %>%
  slice(1:5)
```

``` r
                  mpg cyl disp  hp
Mazda RX4          21   6  160 110
Mazda RX4 Wag      21   6  160 110
Hornet 4 Drive     21   6  258 110
Hornet Sportabout  19   8  360 175
Valiant            18   6  225 105
```

Because magrittr is a package, it introduces another dependency. Native
pipe solves this problem:

``` r
mtcars |>
  filter(hp > 100) |>
  mutate(mpg = round(mpg)) |>
  select(mpg, cyl, disp, hp) |>
  slice(1:5)
```

``` r
                  mpg cyl disp  hp
Mazda RX4          21   6  160 110
Mazda RX4 Wag      21   6  160 110
Hornet 4 Drive     21   6  258 110
Hornet Sportabout  19   8  360 175
Valiant            18   6  225 105
```

Up until R 4.2.0, the native pipe was missing a placeholder to specify
where data from the left hand side should be inserted on the right hand
side. Magrittr uses the `.` symbol for this, which isn't compatible with
the native pipe.

``` r
mtcars %>% lm(mpg ~ cyl, data = .)
```

``` r

Call:
lm(formula = mpg ~ cyl, data = .)

Coefficients:
(Intercept)          cyl
     37.885       -2.876
```

``` r
mtcars |> lm(mpg ~ cyl, data = .)
```

``` r
Error in is.data.frame(data) : object '.' not found
```

One way to go around this problem was to write an anonymous function

``` r
mtcars |> {\(df) lm(mpg ~ cyl, data = df)}()
```

You can see that this is not as elegant or easy when compared to a
simple `.`. This is why this release of R introduces the `_` placeholder
for handle with this problem.

``` r
mtcars |> lm(mpg ~ cyl, data = _)
```

One thing that is different than the `.` placeholder is the fact that
you need to pass the name of the argument that will receive the `_`
placeholder, therefore syntax like `mtcars |> lm(mpg ~ cyl, _)` won't be
valid.

I really like the new `_` placeholder and I will continue using the
native pipe. I hope that some tidyverse functions will adapt to this so
there's no need to return to margittr pipe in situations where base pipe
and `_` placeholder don't work.
