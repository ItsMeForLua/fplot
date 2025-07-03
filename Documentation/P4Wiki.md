# Configuration Options

The `:options` table in `fplot` controls the overall appearance and properties of your plot. It's where you set titles, labels, ranges, output files, and more.

Below is a comprehensive list of all available options. Remember that when using Lua, keys with hyphens (like `:output-file`) must be written using the `["key-name"] = value` syntax.

## General

| **Key**               | **Type** | **Description**                                                                                                                                     | **Example (Fennel)**                           |
| --------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `:title`              | string   | The main title of the plot.                                                                                                                         | `:title "My Awesome Plot"`                     |
| `:output-type`        | string   | The gnuplot terminal to use. Determines the output format. Common values: `wxt` (default, interactive window), `qt`, `pngcairo`, `svg`, `pdfcairo`. | `:output-type "pngcairo"`                      |
| `:output-file`        | string   | The path to save the output file. If `nil`, the plot is displayed in an interactive window.                                                         | `:output-file "my-plot.png"`                   |
| `:size`               | table    | A table `[width, height]` specifying the dimensions of the output in pixels.                                                                        | `:size [800 600]`                              |
| `:font`               | string   | The font to use for text elements (e.g., "Arial", "Helvetica").                                                                                     | `:font "Arial"`                                |
| `:font-size`          | number   | The size of the font.                                                                                                                               | `:font-size 12`                                |
| `:gnuplot-executable` | string   | The path to the gnuplot executable. Defaults to `"gnuplot"`, relying on the system `PATH`.                                                          | `:gnuplot-executable "/opt/local/bin/gnuplot"` |

## Axes and Labels

| **Key**      | **Type** | **Description**                                                                             | **Example (Fennel)**        |
| ------------ | -------- | ------------------------------------------------------------------------------------------- | --------------------------- |
| `:x-label`   | string   | The label for the x-axis.                                                                   | `:x-label "Time (s)"`       |
| `:y-label`   | string   | The label for the y-axis.                                                                   | `:y-label "Velocity (m/s)"` |
| `:z-label`   | string   | The label for the z-axis (for 3D plots).                                                    | `:z-label "Height (m)"`     |
| `:x-range`   | table    | A table `[min, max]` for the x-axis range. Use `"*"` for auto-scaling one end.              | `:x-range [-10 10]`         |
| `:y-range`   | table    | A table `[min, max]` for the y-axis range.                                                  | `:y-range [0 "*"]`          |
| `:z-range`   | table    | A table `[min, max]` for the z-axis range.                                                  | `:z-range [-2 2]`           |
| `:log-scale` | string   | A string specifying which axes should use a logarithmic scale (e.g., `"x"`, `"xy"`, `"z"`). | `:log-scale "y"`            |

## Tics

| **Key**  | **Type** | **Description**                                                                                           | **Example (Fennel)**                             |
| -------- | -------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `:tics`  | table    | A map to control global tic settings for axes.                                                            | `:tics {:xtics "mirror", :ytics "rotate by 90"}` |
| `:xtics` | table    | Sets custom tic marks for the x-axis. Can be a simple list of values or a list of `[label, value]` pairs. | `:xtics [["Low" 0] ["Mid" 50] ["High" 100]]`     |
| `:ytics` | table    | Sets custom tic marks for the y-axis.                                                                     | `:ytics [0 10 20 30]`                            |

## Appearance

| **Key**    | **Type** | **Description**                                                    | **Example (Fennel)**                                |
| ---------- | -------- | ------------------------------------------------------------------ | --------------------------------------------------- |
| `:grid`    | boolean  | If `true`, displays a grid on the plot.                            | `:grid true`                                        |
| `:border`  | boolean  | If `true` (default), displays a border around the plot.            | `:border false`                                     |
| `:key`     | table    | Controls the plot's key (legend). Set `:enabled false` to hide it. | `:key {:enabled true :position "bottom left"}`      |
| `:palette` | string   | Sets the color palette for 3D plots or color-mapped data.          | `:palette "defined (0 'blue', 1 'green', 2 'red')"` |

## Advanced

| **Key**       | **Type** | **Description**                                                            | **Example (Fennel)**                                               |
| ------------- | -------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `:labels`     | list     | A list of tables `[text, x, y, options]` to place text labels on the plot. | `:labels [["Peak" 1.5 9.8 "center font 'Verdana,10'"]]`            |
| `:arrows`     | list     | A list of tables `[x1, y1, x2, y2, options]` to draw arrows.               | `:arrows [[0 0 1.5 9.8 "head filled"]]`                            |
| `:objects`    | list     | A list of tables `[type, definition]` to draw geometric shapes.            | `:objects [["rectangle" "from 0,0 to 1,1 fc rgb 'blue'"]]`         |
| `:multiplot`  | table    | A table to configure a multiplot layout.                                   | `:multiplot {:layout [2 2] :title "My Multiplot"}`                 |
| `:extra-opts` | list     | A list of raw gnuplot commands to be inserted into the script.             | `:extra-opts ["set style data histograms" "set style fill solid"]` |

For options specific to individual datasets (like line color and style), see the **Dataset Configuration** page.
