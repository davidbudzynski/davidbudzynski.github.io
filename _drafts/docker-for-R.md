---
layout : post
title  : "Docker for R projects"
date   : 2024-03-13 18:00
tags   :
---

For years, R users have been known for their knack for analytical thinking, not
necessarily for their expertise in technical infrastructure. Terms like virtual
machines (VMs) and Docker might have seemed like the domain of software
engineers, far removed from the world of statistical models, tidy data, and
ggplots. But as the complexity of data science workflows has grown, the ability
to manage environments, ensure reproducibility, and collaborate effectively has
become critical. That’s where Docker comes in.

At its core, Docker is a platform that helps you package and run applications in
isolated environments called containers. A container is like a virtual box that
holds everything your R project needs to run—R itself, libraries, system
dependencies, and even a specific operating system. Unlike traditional virtual
machines, Docker containers are lightweight, efficient, and portable.

For R users, Docker offers a way to ensure that your code runs exactly the same
anywhere, from your laptop to a cloud server. No more "it works on my machine"
excuses!

You may be thinkging, "But I alredy have R installed on my computer and I use
renv. That's enough, right?" Well, not quite. While renv is excellent for
managing R package dependencies and ensuring reproducibility at the package
level, it falls short in addressing system-level dependencies, R versioning, and
cross-platform compatibility. Docker, by contrast, packages the entire
environment—including the operating system, R version, and required system
libraries—ensuring your project runs identically anywhere. Additionally, Docker
offers seamless integration with other tools and workflows, such as deploying
Shiny apps or APIs, and avoids dependency conflicts by isolating projects
completely. While renv is easier for quick package management, Docker provides a
comprehensive solution for full-stack reproducibility and deployment.

## Getting started with Docker

### Step 1: Install Docker

Docker is available for Windows, macOS, and Linux. You can download it through a
package manger of your choice or directly from the [Docker
website](https://www.docker.com).

### Step 2: Create a Dockerfile or get familiar with the Rocker project

A `Dockerfile` is a simple script that tells Docker how to build your
environment. The easiest way to get started is to use the
[Rocker](https://www.rocker-project.org) and go with a versioned R image. If you
look at my default R project setup, you will see that I use the `rocker/r-ver`
and also install extra applications and version packages tied to specific date.
This ensures that the environment is reproducible and that the project will run
the same way in the future.

```Dockerfile
# license: GPL-2.0-or-later
FROM rocker/r-ver:4.4.2

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV PANDOC_VERSION=default
# specify which vesrion of quarto to install (default is the latest)
ENV QUARTO_VERSION=default

RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/setup_R.sh \
    # note the date at the end of the link here. This is the date of the P3M
    # snapshot and it will install packages in a state from that date.
    https://packagemanager.posit.co/cran/__linux__/jammy/2024-11-20
RUN /rocker_scripts/install_texlive.sh
RUN /rocker_scripts/install_tidyverse.sh
RUN /rocker_scripts/install_python.sh


# install R packages
RUN install2.r --error --skipinstalled --ncpus -1 \
    data.table \
    # ML
    mlr3 \
    tidymodels \
    # NLP
    quanteda \
    # renv \
    psych \
    stringi \
    skimr \
    openxlsx \
    rio \
    fs \
    janitor \
    languageserver \
    styler \
    lintr \
    gt \
    flextable \
    Rcpp \
    # web
    XML \
    jsonlite \
    httr \
    curl \
    # dates and time helper
    anytime \
    # copy data from clipboard
    # datapasta \
    # quick serialization
    qs \
    # for word reports
    officer \
    # logging
    logger \
    # cleanup downloaded packages
    && rm -rf /tmp/downloaded_packages \
    && rm -rf /var/lib/apt/lists/*
# update data.table to the dev version to use the latest features. NOTE that
#this will pull any changes from the data.table repo, so it isn't recommended if
# you want to maintein a stable environment and keep reproducibility
# RUN R -e "data.table::update_dev_pkg()"
# install all packages used by rio for I/O
RUN R -e "rio::install_formats()"

# Once you have scripts to run, they can be added to the image and run during
# the image build process (as opposed to image rung time).
# RUN Rscript file.R
```

