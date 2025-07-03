# Using Macros and Reusable Components with Fplot

A key advantage of using a programmatic plotting library like `fplot` is the ability to create reusable, composable components. This page explains the difference between Gnuplot's native macros and the more flexible approach of using Fennel (or Lua) to manage your plotting..  

### Fennel Macros vs. Lua Functions: A Quick Clarification

It's important to clarify the term "macro."  

* **Fennel**, as a Lisp, has a **true macro system**. This means Fennel macros are code that writes code, running at **compile-time** to transform your program before it even becomes Lua. This allows you to create new syntax and fundamentally change how the language works for your specific needs.  

* **Lua**, on the other hand, does not have a macro system. When we talk about creating "macros" in a Lua context for `fplot`, we are using the term informally to describe a powerful **runtime** pattern: **reusable functions that generate complex data structures** (like tables for options or datasets). We'll refer to these as "reusable components" or "factory functions" in the Lua examples.  

## Gnuplot's Native Macros

Gnuplot has a built-in macro system using the `@` character (e.g., `plot @my_macro`). While `fplot` does not have a feature to directly use these macros in the plot command, you can still **define** them using the `:extra-opts` table.  

This is useful if you have existing Gnuplot scripts or need to set a simple string substitution.  

```fennel
(fplot.plot
  {:options {:title "Plotting with a Gnuplot Macro"
             :x-range [-5 5]
             ;; Define the macro here
             :extra-opts ["my_func = 'sin(x) / x'"]}
   ;; ...
   })
```

## Fennel: The Real Macro System

The true power of fplot comes from using Fennel itself to create reusable components. Because Fennel has a true macro system, you can create very powerful abstractions. But for most plotting scenerios, simple functions that just return tables are usually more than enough. This approach is flexible, powerful, and easy to debug.

### 1. Reusable Data Generators

You can write functions that generate complex datasets.

```fennel
;; A function for generating sinc data
(fn generate-sinc-data [steps]
  (let [data []
        step-size (/ 40 steps)]
    (for [i (- (/ steps 2)) (/ steps 2)]
      (let [x (* i step-size)
            row []]
        (for [j (- (/ steps 2)) (/ steps 2)]
          (let [y (* j step-size)
                r (+ (math.sqrt (+ (* x x) (* y y))) 1e-9)
                z (/ (math.sin r) r)]
            (table.insert row [x y z])))
        (table.insert data row)))
    data))

;; Use the data generator
(local sinc-data (generate-sinc-data 40))
(fplot.splot {:options {:title "Sinc Function"}
              :datasets [{:data sinc-data :style "pm3d"}]}) 
```

### 2. Reusable Style Templates

Create functions that return tables with your preferred plot options. This allows you to maintain a consistent style across many different plots.

```fennel
;; A function for a publication-quality plot style
(fn publication-style [title]
  {:title title
   :font "Helvetica,14"
   :border true
   :grid true})

;; Use the style template by calling the function
(fplot.plot
  {:options (publication-style "My Publication Plot")
   :datasets [...]})
```

### 3. Putting It All Together

The real magic happens when you combine these components. You can define a base style, a plot-specific style, and then merge them together. The example below is a complete, and runnable script. Feel free to try it!

#### Fennel

```fennel
(local fplot (require :fplot))

;; Helper function to recursively clone a table.
(fn table-clone [tbl]
  (let [copy {}]
    (each [k v (pairs tbl)]
      (tset copy k (if (= (type v) "table") (table-clone v) v)))
    copy))

;; Helper function to merge tables.
(fn merge-tables [a b]
  (let [result (table-clone a)]
    (each [k v (pairs b)]
      (if (and (= (type v) "table") (= (type (. result k)) "table"))
          (tset result k (merge-tables (. result k) v))
          (tset result k v)))
    result))

;; --- Our Reusable Components ---
(fn generate-line-data [num-points]
  (let [data []]
    (for [i 1 num-points]
      (table.insert data [i (math.random)]))
    data))

(fn base-style []
  {:font "Arial,12"
   :grid true
   :output-type "pngcairo"
   :size [800 600]})

(fn scatter-plot-style []
  {:style "points"
   :pointtype 7
   :color "#3366cc"})

;; --- The Plotting Script ---
(local my-data (generate-line-data 100))

(local plot-specific-opts
  {:title "My Composed Plot"
   :x-label "Index"
   :y-label "Random Value"
   :output-file "my-composed-plot.png"})

(local final-options (merge-tables (base-style) plot-specific-opts))
(local final-dataset (merge-tables (scatter-plot-style) {:data my-data}))

(fplot.plot {:options final-options
             :datasets [final-dataset]})

(print "Plot generated at my-new-composed-plot.png")
```

---

#### The Lua Equivalent: Reusable Functions

```lua
require("fennel").install()
local fplot = require("fplot")

-- Helper functions
local function table_clone(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      copy[k] = table_clone(v)
    else
      copy[k] = v
    end
  end
  return copy
end

local function merge_tables(a, b)
  local result = table_clone(a)
  for k, v in pairs(b) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = merge_tables(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

-- --- Our Reusable Components ---
local function generate_line_data(num_points)
  local data = {}
  for i = 1, num_points do
    table.insert(data, {i, math.random()})
  end
  return data
end

local function base_style()
  return {
    font = "Arial,12",
    grid = true,
    ["output-type"] = "pngcairo",
    size = {800, 600}
  }
end

local function scatter_plot_style()
  return {
    style = "points",
    pointtype = 7,
    color = "#3366cc"
  }
end

-- --- The Plotting Script ---
local my_data = generate_line_data(100)

local plot_specific_opts = {
  title = "My Composed Plot",
  ["x-label"] = "Index",
  ["y-label"] = "Random Value",
  ["output-file"] = "my-composed-plot.png"
}

local final_options = merge_tables(base_style(), plot_specific_opts)
local final_dataset = merge_tables(scatter_plot_style(), {data = my_data})

fplot.plot({
  options = final_options,
  datasets = {final_dataset}
})

print("Plot generated at my-composed-plot.png")
```
