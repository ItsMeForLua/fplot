# Getting Started Tutorial

This tutorial will walk you through the basics of creating a plot with fplot. We'll create a simple chart with two datasets and customize its appearance.

## The Core Idea

A plot in fplot is defined by a single configuration table passed to either the `fplot.plot` (for 2D) or `fplot.splot` (for 3D) function. This table has two main keys:

- `:options`: A table that controls the overall appearance of the plot (title, labels, etc.).

- `:datasets`: A list of tables, where each table defines a set of data to be plotted.

Before running any examples, make sure you have followed the setup instructions in the **README**. The examples below assume `fplot.fnl` is in your path. For Lua examples, they assume you have `fennel.lua` and are calling `require("fennel").install()` first.

## Step 1: Your First Plot

Let's start with the simplest possible plot.

### Fennel

```fennel
(local fplot (require :fplot))

(fplot.plot
  {:options {:title "My First Plot"}
   :datasets [{:data [1 5 3 8 6]}]})
```

### Lua

```lua
-- First, install the fennel loader
require("fennel").install()
local fplot = require("fplot")

fplot.plot({
  options = { title = "My First Plot" },
  datasets = {
    { data = {1, 5, 3, 8, 6} }
  }
})
```

When you run this code, fplot will open an interactive window displaying a line chart. The y-values are `1, 5, 3, 8, 6`, and the x-values default to their indices (`1, 2, 3, 4, 5`).

## Step 2: Working with X and Y Coordinates

Most of the time, you'll want to specify both X and Y coordinates. You can do this by providing a list of pairs (or small tables) in the `:data` field. Let's plot the function `y = x^2`.

### Fennel

```fennel
(local fplot (require :fplot))

(local squared-data [])
(for [x -5 5]
  (table.insert squared-data [x (* x x)]))

(fplot.plot
  {:options {:title "Parabola"
             :x-label "x"
             :y-label "y = x^2"
             :grid true}
   :datasets [{:title "x^2"
               :style "points"
               :data squared-data}]})
```

### Lua

```lua
require("fennel").install()
local fplot = require("fplot")

local squared_data = {}
for x = -5, 5 do
  table.insert(squared_data, {x, x*x})
end

fplot.plot({
  options = {
    title = "Parabola",
    -- IMPORTANT: Keys with hyphens must be quoted in Lua
    ["x-label"] = "x",
    ["y-label"] = "y = x^2",
    grid = true
  },
  datasets = {
    {
      title = "x^2",
      style = "points",
      data = squared_data
    }
  }
})
```

In this example, we:

- Generated data points for `y = x^2` from `x` = -5 to `5`.

- Set a title for the plot and labels for the axes in the `:options` table.

- Enabled a grid by setting `:grid true`.

- In the dataset, we gave it a `:title` to be shown in the plot's key and changed the `:style` to `"points"`.

## Step 3: Plotting Multiple Datasets

To plot multiple datasets, simply add more tables to the `:datasets` list. Let's add `y = x^3` to our previous plot.

### Fennel

```fennel
(local fplot (require :fplot))

;; Generate data
(local squared-data [])
(local cubed-data [])
(for [x -5 5 0.5]
  (table.insert squared-data [x (* x x)])
  (table.insert cubed-data [x (* x x x)]))

(fplot.plot
  {:options {:title "Polynomials"
             :x-label "x"
             :y-label "y"
             :grid true
             :x-range [-5 5]
             :y-range [-125 125]}
   :datasets [{:title "x^2" :style "lines" :data squared-data}
              {:title "x^3" :style "lines" :data cubed-data}]})
```

### Lua

```lua
require("fennel").install()
local fplot = require("fplot")

-- Generate data
local squared_data = {}
local cubed_data = {}
for i = -10, 10 do
    local x = i * 0.5
    table.insert(squared_data, {x, x*x})
    table.insert(cubed_data, {x, x*x*x})
end

fplot.plot({
  options = {
    title = "Polynomials",
    ["x-label"] = "x",
    ["y-label"] = "y",
    grid = true,
    ["x-range"] = {-5, 5},
    ["y-range"] = {-125, 125}
  },
  datasets = {
    {title = "x^2", style = "lines", data = squared_data},
    {title = "x^3", style = "lines", data = cubed_data}
  }
})
```

Here, we've added a second dataset for `y = x^3`. We also added `:x-range` and `:y-range` to the options to set the viewing window of the plot. fplot automatically assigns different colors and line styles to each dataset.

## Step 4: Saving to a File

If you want to save your plot instead of displaying it in a window, use the `:output-file` and `:output-type` options.

### Fennel

```fennel
(local fplot (require :fplot))

;; Generate data
(local squared-data [])
(local cubed-data [])
(for [x -5 5 0.5]
  (table.insert squared-data [x (* x x)])
  (table.insert cubed-data [x (* x x x)]))

(fplot.plot
  {:options {:title "Polynomials"
             ;; ... other options from Step 3
             :x-range [-5 5]
             :y-range [-125 125]
             :output-file "polynomials.svg"
             :output-type "svg"}
   :datasets [{:title "x^2" :style "lines" :data squared-data}
              {:title "x^3" :style "lines" :data cubed-data}]})
```

### Lua

```lua
require("fennel").install()
local fplot = require("fplot")

-- Generate data
local squared_data = {}
local cubed_data = {}
for i = -10, 10 do
    local x = i * 0.5
    table.insert(squared_data, {x, x*x})
    table.insert(cubed_data, {x, x*x*x})
end

fplot.plot({
  options = {
    title = "Polynomials",
    ["output-file"] = "polynomials.svg",
    ["output-type"] = "svg",
    ["x-label"] = "x",
    ["y-label"] = "y",
    grid = false,
    ["x-range"] = {-5, 5},
    ["y-range"] = {-125, 125}
  },
  datasets = {
    {title = "x^2", style = "lines", data = squared_data},
    {title = "x^3", style = "lines", data = cubed_data}
  }
})
```

This will create an SVG file named `polynomials.svg` in the same directory. Common output types include `pngcairo`, `svg`, `pdfcairo`, and `jpeg`.

You now know the fundamentals of using fplot! To learn about all the available customization options, head over to the **Configuration Options** and **Dataset Configuration** pages on the wiki.
