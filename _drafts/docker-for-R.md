---
layout : post
title  : "Docker for R projects"
date   : 2024-11-20 18:08
tags   : [R, Docker, Reproducibility, software]
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

### Step 3: Build Your Docker Image

In your terminal, navigate to the directory containing the Dockerfile and run:

```bash
docker build -t my-r-project .
```

This command creates a Docker image named my-r-project, containing your R environment and scripts.

### Step 4: Run the Container

Run your container with:

```bash
docker run -it my-r-project
```

This starts a container where your R script will execute exactly as defined.

### Step 5: Explore all the possibilities

Docker is a powerful tool with many features and integrations. There are many smart people out there who created nice base images and scripts to help you get started. The Rocker project is a great place to start, but you can also explore other images and scripts on GitHub. 

Additionally, you should read [Building reproducible analytical pipelines with R](https://raps-with-r.dev/) by Bruno Rodrigues. He goes into more detail about how to use Docker for R projects and how to create a reproducible workflow. I have my own [small setup](https://github.com/davidbudzynski/R-project-bootstrap) which uses Makefiles to build the Docker image and run the container. This way I can easily share the project with others and ensure that the environment is the same for everyone. The most important thing is to start and learn as you go. Once you keep using docker, you will see the benefits and how it can help you in your daily work.

## Closing thoughts

Docker might seem like a tool for "techies," but it’s actually a powerful ally for R users. By taking the guesswork out of environment management and enabling seamless collaboration, Docker helps you focus on what really matters: your data and analysis.

So, whether you’re an academic researcher, data scientist, or educator, give Docker a try. You don’t have to be a tech expert—just a curious problem-solver looking for better ways to work. With Docker, your R projects will be more reproducible, portable, and future-proof than ever before.