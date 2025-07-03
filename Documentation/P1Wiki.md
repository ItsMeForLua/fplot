# Welcome to the fplot Wiki!

**fplot** is a plotting library for Fennel and Lua that makes it easy to create a wide range of plots using Gnuplot. This wiki provides comprehensive documentation to help you get started making the most of its features.

## Getting Started

If you're new to `fplot`, here are a few pages to get you up and running:

- [**Installation**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Installation "null")**:** Learn how to install `fplot` and its dependencies.

- [**Getting Started Tutorial**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Getting-Started "null")**:** A step-by-step guide to creating your first plot.

## Core Concepts

Understanding these two concepts is key to using `fplot` effectively:

- [**Configuration Options**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Configuration-Options "null")**:** This is where you define the overall appearance of your plot, such as its title, labels, size, and output format.

- [**Dataset Configuration**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Dataset-Configuration "null")**:** This is where you define the data to be plotted, along with its style, title, and other attributes.

## Advanced Topics

Once you've mastered the basics, you can explore more advanced features:

- [**Advanced Features**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Advanced-Features "null")**:** Learn about creating multiplots, adding custom labels and arrows, and more.

- [**Examples**](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Examples "null")**:** A gallery of examples showcasing various types of plots you can create with `fplot`.

- [BioTech]() A gallery of examples showcasing biotech relates plots.

## Why fplot?

`fplot` aims to provide a more idiomatic and comfortable way to use `gnuplot` from Fennel and Lua. Instead of building command strings manually, you can describe your plot with data structures, letting `fplot` handle the translation to `gnuplot` commands. This makes your plotting code cleaner, more readable, and easier to maintain.

## Why Fennel?

Fplot is written in Fennel and is designed to feel most natural when used from a `.fnl` file. While it has first-class support for Lua, here are a few reasons why you might enjoy using Fennel for your plotting scripts:

- **Concise Syntax for Data:** Fennel's Lisp-based syntax is exceptionally clean for defining the nested tables that fplot relies on. This often results in less visual noise (fewer commas, brackets, and braces) and makes complex configurations easier to read at a glance.

- **Powerful Macros:** Fennel offers a true, Lisp-style macro system, allowing you to extend the language with new syntax and create powerful abstractions that are impossible in pure Lua. While not necessary for basic plotting, it opens the door for creating highly customized plotting DSLs (Domain-Specific Languages) tailored to your specific needs.

- **Seamless Lua Interoperability:** Fennel compiles directly to Lua. This means you lose none of Lua's performance or its rich ecosystem. You can use any Lua library (including LuaJIT) and get the best of both worlds: a powerful Lisp syntax on a fast, proven runtime.

- **A More Ergonomic API:** The fplot API was designed with Fennel's keywords (e.g., `:title`, `:x-label`) in mind. While perfectly usable from Lua with the `["key-name"]` syntax, the original `kebab-case` keywords feel most at home in a Fennel environment.

> You can find the official documentation for fennel, [here](https://fennel-lang.org/).
