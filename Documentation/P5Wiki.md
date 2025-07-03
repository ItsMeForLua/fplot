# Dataset Configuration

The `:datasets` key in your main configuration table holds a list of tables. Each of these tables defines a single dataset to be drawn on your plot.

Here is a guide to the options available for configuring an individual dataset.

## Core Dataset Properties

| Key      | Type            | Description                                                                                                                 | Example (Fennel)                            |
| -------- | --------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `:data`  | table or string | The data for the plot. Can be a list of values (y-axis), a list of `[x, y]` pairs, or a filename string.                    | `:data [1 4 9 16]` or `:data "my-data.dat"` |
| `:title` | string          | The title of the dataset, which appears in the plot's key (legend).                                                         | `:title "Temperature"`                      |
| `:style` | string          | The plotting style. Common values: `lines`, `points`, `linespoints`, `dots`, `impulses`, `boxes`, `errorbars`.              | `:style "linespoints"`                      |
| `:using` | string          | Specifies which columns to use from the data. For example, `"1:3"` plots column 1 vs. column 3.                             | `:using "1:3:4" with yerrorbars`            |
| `:axes`  | string          | The axes to plot this dataset against (e.g., `x1y1`, `x1y2`, `x2y2`). Useful for plots with multiple y-axes.                | `:axes "x1y2"`                              |
| `:type`  | string          | The type of data source. Defaults to `"inline"`. Can be set to `"file"` to explicitly indicate the `:data` field is a path. | `:type "file"`                              |

## Styling Properties

These options override the default styles for a specific dataset.

| Key          | Type   | Description                                                          | Example (Fennel)                      |
| ------------ | ------ | -------------------------------------------------------------------- | ------------------------------------- |
| `:color`     | string | The color of the line or points. Can be a named color or a hex code. | `:color "#ff0000"` or `:color "blue"` |
| `:linetype`  | number | The gnuplot linetype identifier.                                     | `:linetype 2`                         |
| `:pointtype` | number | The gnuplot pointtype identifier.                                    | `:pointtype 7`                        |
| `:fillstyle` | string | The fill style for filled shapes like boxes or histograms.           | `:fillstyle "solid 0.5 border"`       |

## Data Formats

`fplot` is flexible in how you provide your data.

### 1. Simple Y-Values (List)

A simple list of numbers will be plotted against their indices (1, 2, 3, ...).

```fennel
:data [10 12 15 11 9]
```

### 2. X-Y Pairs (List of Lists/Tables)

This is the most common format for 2D plots.

```fennel
:data [[0 10] [1 12] [2 15] [3 11] [4 9]]
```

### 3. Columnar Data (Transposed Table)

If it's more convenient to provide data as columns, fplot will automatically transpose it. This is detected when the number of inner tables (columns) is less than the number of items in the first inner table.

```fennel
;; This is treated the same as the X-Y pairs above
:data [[0 1 2 3 4]      ;-- x-values
       [10 12 15 11 9]]  ;-- y-values
```

### 4. 3D Grid Data (for `splot`)

For surface plots (e.g., with `pm3d`), provide a list of rows, where each row is a list of `[x y z]` points. `fplot` formats this correctly by adding blank lines between rows for gnuplot.

```fennel
:data [;; Row 1
       [[0 0 5] [0 1 6] [0 2 7]]
       ;; Row 2
       [[1 0 8] [1 1 9] [1 2 8]]
       ;; Row 3
       [[2 0 7] [2 1 6] [2 2 5]]]
```

### 5. Data from a File

To plot data directly from a file, provide the filename as a string in the `:data` field.

```fennel
:data "path/to/your/data.dat"
```

The data file should be plain text, with columns separated by whitespace. For example `data.dat`:

```
# X Y
0  10
1  12
2  15
3  11
4  9
```
