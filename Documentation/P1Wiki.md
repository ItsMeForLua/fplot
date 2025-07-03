# Welcome to the fplot Wiki!

**fplot** is a plotting library for Fennel and Lua that makes it easy to create a wide range of plots using Gnuplot. This wiki provides comprehensive documentation to help you get started making the most of its features.

## Getting Started

If you're new to `fplot`, here are a few pages to get you up and running:

- [**Installation**](P2Wiki.md)**:** Learn how to install `fplot` and its dependencies.

- [**Getting Started Tutorial**](P3Wiki.md)**:** A step-by-step guide to creating your first plot.

## Core Concepts

Understanding these two concepts is key to using `fplot` effectively:

- [**Configuration Options**](P4Wiki.md)**:** This is where you define the overall appearance of your plot, such as its title, labels, size, and output format.

- [**Dataset Configuration**](P5Wiki.md)**:** This is where you define the data to be plotted, along with its style, title, and other attributes.

## Advanced Topics

Once you've mastered the basics, you can explore more advanced features:

- [**Advanced Features**](P6Wiki.md)**:** Learn about creating multiplots, adding custom labels and arrows, and more.

    > [**Macros**](P7Wiki.md)**:** A dedicated page for creating various macros

- [**Examples**](P8Wiki.md)**:** A gallery of examples showcasing various types of plots you can create with `fplot`.

- [**BioTech**](P9Wiki.md)**:** A gallery of examples showcasing biotech relates plots.

## Why fplot?

`fplot` makes `gnuplot` a programmatic citizen in your Fennel and Lua projects. Instead of shelling out to separate scripts, you can define, generate, and integrate plots directly within your application's (and/or pipeline's) logic. `fplot` replaces the error-prone process of building command strings with a clean, table-based API where you describe your plot as a data structure. This makes your plotting code more readable, but more importantly, it makes your plots composable: you can build, combine, and reuse styles and datasets as regular pieces of data in your code.

## Why Fennel?

`fplot` is written in Fennel and is designed to feel most natural when used from a `.fnl` file. While it has first-class support for Lua, here are a few reasons why you might enjoy using Fennel for your plotting scripts:

- **Concise Syntax for Data:** Fennel's Lisp-based syntax is exceptionally clean for defining the nested tables that fplot relies on. This often results in less visual noise (fewer commas, brackets, and braces) and makes complex configurations easier to read at a glance.

- **Powerful Macros:** Fennel offers a true, Lisp-style macro system, allowing you to extend the language with new syntax and create powerful abstractions that are impossible in pure Lua. While not necessary for basic plotting, it opens the door for creating highly customized plotting DSLs (Domain-Specific Languages) tailored to your specific needs.

- **Seamless Lua Interoperability:** Fennel compiles directly to Lua. This means you lose none of Lua's performance or its rich ecosystem. You can use any Lua library (including LuaJIT) and get the best of both worlds: a powerful Lisp syntax on a fast, proven runtime.

- **A More Ergonomic API:** The fplot API was designed with Fennel's keywords (e.g., `:title`, `:x-label`) in mind. While perfectly usable from Lua with the `["key-name"]` syntax, the original `kebab-case` keywords feel most at home in a Fennel environment.
---
**Resources**

Fennel Language. (n.d.). *Official documentation*. [https://fennel-lang.org/](https://fennel-lang.org/) \
Gnuplot. (n.d.). *Official documentation*. [gnuplot documentation](http://gnuplot.info/documentation.html)
