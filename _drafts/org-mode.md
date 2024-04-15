---
layout : post
title  : "Org mode for C++ notebooks"
date   : 2024-03-13 18:00
tags   :
---

I recently had to write some documentation for people who are not familiar with
C++ but know other programming languages and understand the basics of working
inside notebooks. I thought to myself that org mode could be a good tool for
this, as it can compile the code and put the output right next to it in an HTML
or PDF format.

## What is Org Mode

[Org mode][1] is a major mode for [GNU Emacs][2]. It is used for keeping notes,
maintaining TODO lists, planning projects, and authoring documents with a fast
and effective plain-text system. It is also an authoring system with unique
support for literate programming and reproducible research. It is a simple
markup language that can be exported to HTML, PDF, and other formats. It is a
much more powerful version of markdown.

## How to use Org Mode's C++ code blocks

This article would be too long if I were to explain all the features of org
mode, how to set it up, and how to use it. Instead, I will focus on how to use
org mode to write C++ code blocks and export them to HTML or PDF. For a beginner
friendly setup, try [Doom Emacs][3]. It is a pre-configured version of Emacs.

Org mode, similiar to Jupyter notebooks, allows you to write code blocks in the
file and execute them. The source block looks like this:

```org
#+BEGIN_SRC cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

[1]: https://orgmode.org/
[2]: https://www.gnu.org/software/emacs/
[3]: https://github.com/doomemacs/doomemacs

