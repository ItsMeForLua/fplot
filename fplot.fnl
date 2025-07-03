; fplot - A Declarative Plotting Library for Fennel and Lua
;
; Copyright (C) 2025 Andrew D. France
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public License
; as published by the Free Software Foundation; either version 3
; of the License, or (at your option) any later version.
;
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public License
; along with this library.  If not, see <https://www.gnu.org/licenses/>.

(local io _G.io)

(fn table-clone [tbl]
  "Recursively clone a table."
  (let [copy {}]
    (each [k v (pairs tbl)]
      (tset copy k (if (= (type v) "table") (table-clone v) v)))
    copy))

(fn merge-tables [a b]
  "Deep merge table b into a, preferring values from b."
  (var result (table-clone a))
  (each [k v (pairs b)]
    (if (and (= (type v) "table") (= (type (. result k)) "table"))
        (tset result k (merge-tables (. result k) v))
        (tset result k v)))
  result)

(local default-options
  {:title ""
   :output-type "wxt"
   :output-file nil
   :size [600 480]
   :font nil
   :font-size nil
   :x-label "" :y-label "" :z-label ""
   :x-range nil :y-range nil :z-range nil
   :log-scale ""
   :key {:enabled true :position "right top"}
   :grid false :border true
   :palette nil
   :color nil
   :linetype nil
   :pointtype nil
   :fillstyle nil
   :labels []
   :arrows []
   :objects []
   :tics {}
   :multiplot nil
   :extra-opts []
   :gnuplot-executable "gnuplot"})

(local default-dataset
  {:title "" :style "lines" :using nil :axes "x1y1"
   :type "inline" :data []
   :color nil :linetype nil :pointtype nil :fillstyle nil})

;; A list of options that can only be set once, before multiplot.
(local global-keys [:output-type :output-file :size :font :font-size :gnuplot-executable :multiplot])

(fn is-global-key [key]
  "Checks if a key is a global-only option."
  (var found false)
  (each [_ gkey (ipairs global-keys)]
    (when (= gkey key)
      (set found true)))
  found)

(fn filter-non-nil [xs]
  (icollect [_ v (ipairs xs)]
    (when (not= v nil) v)))

(fn safe-concat [tbl separator]
  (let [filtered (filter-non-nil tbl)
        sep (or separator "")]
    (table.concat filtered sep)))

(fn option->cmd [k v opts]
  (case k
    :title
      (when (and v (not= v "")) (.. "set title \"" v "\"\n"))
    :output-type
      (let [term (when v (string.lower v))
            size-str (when (and opts.size (= (type opts.size) "table"))
                       (.. " size " (. opts.size 1) "," (. opts.size 2)))
            font-str (when opts.font
                       (.. " font \"" opts.font (if opts.font-size (.. "," opts.font-size) "") "\""))]
        (case term
          "qt"      (.. "set term qt" (or size-str "") (or font-str "") "\n")
          "windows" (.. "set term windows" (or size-str "") (or font-str "") "\n")
          "wxt"     (.. "set term wxt" (or size-str "") (or font-str "") "\n")
          _         (.. "set term " v (or size-str "") (or font-str "") "\n")))
    :output-file
      (when (and v (not= v nil)) (.. "set output \"" v "\"\n"))
    :x-label
      (when (and v (not= v "")) (.. "set xlabel \"" v "\"\n"))
    :y-label
      (when (and v (not= v "")) (.. "set ylabel \"" v "\"\n"))
    :z-label
      (when (and v (not= v "")) (.. "set zlabel \"" v "\"\n"))
    :x-range
      (when (and v (= (type v) "table")) (.. "set xrange [" (table.concat v ":") "]\n"))
    :y-range
      (when (and v (= (type v) "table")) (.. "set yrange [" (table.concat v ":") "]\n"))
    :z-range
      (when (and v (= (type v) "table")) (.. "set zrange [" (table.concat v ":") "]\n"))
    :log-scale
      (when (and v (not= v "")) (.. "set logscale " v "\n"))
    :grid
      (if v "set grid\n" "unset grid\n")
    :border
      (if v "set border\n" "unset border\n")
    :palette
      (when v (.. "set palette " v "\n"))
    :color
      (when v (.. "set style line 1 lc rgb \"" v "\"\n"))
    :linetype
      (when v (.. "set linetype " v "\n"))
    :pointtype
      (when v (.. "set pointtype " v "\n"))
    :fillstyle
      (when v (.. "set style fill " v "\n"))
    :labels
      (when (and v (= (type v) "table"))
        (safe-concat
          (icollect [_ l (ipairs v)]
            (when (and l (. l 1) (. l 2) (. l 3))
              (.. "set label \"" (. l 1) "\" at " (. l 2) "," (. l 3)
                  (if (. l 4) (.. " " (. l 4)) "") "\n")))))
    :arrows
      (when (and v (= (type v) "table"))
        (safe-concat
          (icollect [_ a (ipairs v)]
            (when (and a (. a 1) (. a 2) (. a 3) (. a 4))
              (.. "set arrow from " (. a 1) "," (. a 2)
                  " to " (. a 3) "," (. a 4)
                  (if (. a 5) (.. " " (. a 5)) "") "\n")))))
    :objects
      (when (and v (= (type v) "table"))
        (safe-concat
          (icollect [_ o (ipairs v)]
            (when (and o (. o 1) (. o 2))
              (.. "set object " (. o 1) " " (. o 2) "\n")))))
    :tics
      (when (and v (= (type v) "table"))
        (safe-concat
          (icollect [axis tv (pairs v)]
            (when tv (.. "set " axis "tics " tv "\n")))))
    :xtics
      (when (and v (= (type v) "table"))
        (if (= (type (. v 1)) "table")
            (let [tic-pairs (icollect [_ pair (ipairs v)]
                              (when (and pair (. pair 1) (. pair 2))
                                (let [label (string.gsub (tostring (. pair 1)) "\n" "\\n")]
                                  (.. "\"" label "\" " (. pair 2)))))]
              (.. "set xtics (" (safe-concat tic-pairs ", ") ")\n"))
            (.. "set xtics (" (safe-concat (icollect [_ val (ipairs v)] (tostring val)) ", ") ")\n")))
    :ytics
      (when (and v (= (type v) "table"))
        (if (= (type (. v 1)) "table")
            (let [tic-pairs (icollect [_ pair (ipairs v)]
                              (when (and pair (. pair 1) (. pair 2))
                                (let [label (string.gsub (tostring (. pair 1)) "\n" "\\n")]
                                  (.. "\"" label "\" " (. pair 2)))))]
              (.. "set ytics (" (safe-concat tic-pairs ", ") ")\n"))
            (.. "set ytics (" (safe-concat (icollect [_ val (ipairs v)] (tostring val)) ", ") ")\n")))
    :key
      (if (and v (. v :enabled))
          (.. "set key " (. v :position) "\n")
          "unset key\n")
    :multiplot
      (when v
        (let [layout (or (. v :layout) [1 1])
              title (or (. v :title) "")]
          (.. "set multiplot layout " (. layout 1) "," (. layout 2)
              (if (not= title "") (.. " title \"" title "\"") "") "\n")))
    :extra-opts
      (when (and v (= (type v) "table"))
        (let [filtered-opts (filter-non-nil v)]
          (when (> (length filtered-opts) 0)
            (.. (safe-concat filtered-opts "\n") "\n"))))
    _ ""))

(fn dataset-style-cmd [ds]
  (let [opts {}]
    (when ds.color (tset opts :lc (.. "rgb \"" ds.color "\"")))
    (when ds.linetype (tset opts :lt ds.linetype))
    (when ds.pointtype (tset opts :pt ds.pointtype))
    (when ds.fillstyle (tset opts :fs ds.fillstyle))
    (if (> (length opts) 0)
        (.. " " (safe-concat (icollect [k v (pairs opts)]
                              (.. (string.gsub (tostring k) "^:" "") " " v)) " "))
        "")))

(fn dataset->plot-clause [ds]
  "Builds a plot clause. It now expects ds.data to be a filename."
  (let [{:data filename :using using :style style :title title} ds]
    (var clause (.. "\"" filename "\""
                    (if using (.. " using " using) "")
                    " with " style
                    (dataset-style-cmd ds)))
    (when (and title (not= title ""))
      (set clause (.. clause " title \"" title "\"")))
    clause))

(fn format-data [data]
  "Formats a data table into a string for gnuplot, handling 2D and 3D grid data."
  (if (or (not= (type data) "table") (= (length data) 0))
      (do
        (print "fplot warning: format-data received invalid or empty table.")
        "") ;; Return empty string if data is invalid
      ;; Else, process the data
      (let [first-row (. data 1)
            is-grid-data (and (= (type first-row) "table")
                              (> (length first-row) 0)
                              (= (type (. first-row 1)) "table"))]
        (if is-grid-data
            ;; Handle splot grid data (e.g., for pm3d)
            (let [scan-lines (icollect [_ row (ipairs data)]
                               (let [points-in-row (icollect [_ point (ipairs row)]
                                                     (safe-concat point "\t"))]
                                 (safe-concat points-in-row "\n")))]
              (.. (safe-concat scan-lines "\n\n") "\n"))
            ;; Handle 2D plot data (original logic)
            (let [is-columnar (and (= (type data) "table")
                                   (> (length data) 0)
                                   (= (type (. data 1)) "table")
                                   (> (length (. data 1)) 0)
                                   (< (length data) (length (. data 1))))
                  lines (if is-columnar
                            (let [cols data]
                              (icollect [i _ (ipairs (. cols 1))]
                                (let [row-data (icollect [_ col (ipairs cols)]
                                                 (. col i))]
                                  (safe-concat row-data "\t"))))
                            (icollect [_ row (ipairs data)]
                              (if (= (type row) "table")
                                  (safe-concat row "\t")
                                  (when row (tostring row)))))]
              (let [filtered-lines (filter-non-nil lines)]
                (when (> (length filtered-lines) 0)
                  (.. (safe-concat filtered-lines "\n") "\n"))))))))

(fn build-plot-command [kind opts datasets]
  "Builds the plot command and its local setup for one plot."
  (let [;; For subplots, we only want local options.
        setup-cmds (filter-non-nil (icollect [k v (pairs opts)]
                                   (when (not (is-global-key k))
                                     (option->cmd k v opts))))
        plot-clauses (filter-non-nil (icollect [_ ds (ipairs datasets)]
                                     (dataset->plot-clause ds)))
        plot-cmd (if (> (length plot-clauses) 0)
                     (.. kind " " (safe-concat plot-clauses ", ") "\n")
                     (.. kind " x\n"))]
    (.. (safe-concat setup-cmds "")
        plot-cmd)))

(fn get-tempfile [prefix ext]
  "Get a temporary filename with a given prefix and extension."
  (let [tmp (or (os.getenv "TMP") (os.getenv "TEMP") ".")
        name (if (= tmp ".")
                 (.. prefix "-" (math.random 1000000) "." ext)
                 (.. tmp "/" prefix "-" (math.random 1000000) "." ext))]
    name))

(fn execute-script [script-content gnuplot-executable opts]
  "Writes a script to a temp file and executes it with gnuplot."
  (let [script-filename (get-tempfile "fplot-script" "gp")]
    (let [file (io.open script-filename :w)]
      (assert file (.. "Failed to create temp script file: " script-filename))
      (file:write script-content)
      (when (not opts.output-file)
        (file:write "\npause mouse close\n"))
      (file:close))

    (let [command (if opts.output-file
                      (.. gnuplot-executable " " script-filename)
                      (.. gnuplot-executable " -p " script-filename))]
      (print (.. "--- Running command ---\n" command "\n-----------------------"))
      (print script-content) ;; For debugging
      (local result (os.execute command))
      (print (.. "\n--- Gnuplot finished with result: " (tostring result) " ---")))
    ;; Return filename for cleanup
    script-filename))

(fn process-datasets [datasets]
  "Writes inline data to temp files and returns new datasets and temp file list."
  (let [temp-files []
        processed-datasets []]
    (each [_ ds (ipairs datasets)]
      (if (and (= ds.type "inline") (> (length ds.data) 0))
          (let [data-filename (get-tempfile "fplot-data" "dat")
                data-content (format-data ds.data)
                file (io.open data-filename :w)]
            (assert file (.. "Failed to create temp data file: " data-filename))
            (file:write data-content)
            (file:close)
            (table.insert temp-files data-filename)
            (let [new-ds (table-clone ds)]
              (set new-ds.data data-filename)
              (table.insert processed-datasets new-ds)))
          (when (= ds.type "file")
            (table.insert processed-datasets (table-clone ds)))))
    [processed-datasets temp-files]))

(fn run-plot [kind config]
  "Handles a single plot execution."
  (let [opts (merge-tables default-options (or (. config :options) config))
        gnuplot-executable opts.gnuplot-executable
        datasets (icollect [_ ds (ipairs (or (. config :datasets) []))]
                   (merge-tables default-dataset ds))
        [processed-datasets data-files] (process-datasets datasets)
        ;; For single plots, all options are local
        local-setup-cmds (filter-non-nil (icollect [k v (pairs opts)]
                                           (option->cmd k v opts)))
        script-parts [(safe-concat local-setup-cmds "")]
        plot-clauses (filter-non-nil (icollect [_ ds (ipairs processed-datasets)]
                                     (dataset->plot-clause ds)))
        plot-cmd (if (> (length plot-clauses) 0)
                     (.. kind " " (safe-concat plot-clauses ", ") "\n")
                     (.. kind " x\n"))]
    (table.insert script-parts plot-cmd)
    (let [script-content (table.concat script-parts "")
          script-file (execute-script script-content gnuplot-executable opts)
          all-temp-files (doto data-files (table.insert script-file))]
      (print "\nCleaning up temporary files...")
      (each [_ filename (ipairs all-temp-files)]
        (os.remove filename))
      (print "Done."))))

(fn run-multiplot [kind configs]
  "Handles multiplot execution by building a single script."
  (let [num-configs (length configs)
        multiplot-config (. configs num-configs)
        main-opts (merge-tables default-options (or (. multiplot-config :options) {}))
        gnuplot-executable main-opts.gnuplot-executable
        all-temp-files []
        script-parts []]

    (assert (and main-opts.multiplot) "Multiplot options must be in the last table argument.")

    ;; 1. Add ONLY global setup commands from the main config
    (let [main-setup-cmds (filter-non-nil (icollect [k v (pairs main-opts)]
                                            (when (is-global-key k)
                                              (option->cmd k v main-opts))))]
      (table.insert script-parts (safe-concat main-setup-cmds "")))

    ;; 2. Loop through each subplot configuration
    (for [i 1 (- num-configs 1)]
      (let [plot-config (. configs i)
            opts (merge-tables default-options (or (. plot-config :options) {}))
            datasets (icollect [_ ds (ipairs (or (. plot-config :datasets) []))]
                       (merge-tables default-dataset ds))
            [processed-datasets data-files] (process-datasets datasets)]
        (each [_ f (ipairs data-files)] (table.insert all-temp-files f))
        (table.insert script-parts (build-plot-command kind opts processed-datasets))))

    ;; 3. Add unset multiplot and finalize
    (table.insert script-parts "unset multiplot\n")
    (let [script-content (table.concat script-parts "")
          script-filename (execute-script script-content gnuplot-executable main-opts)]
      (table.insert all-temp-files script-filename))

    (print "\nCleaning up temporary files...")
    (each [_ filename (ipairs all-temp-files)]
      (os.remove filename))
    (print "Done.")))

(fn plot [...]
  "Accepts one or more plot configurations. If more than one, it enables multiplot."
  (let [configs [...]
        num-configs (length configs)]
    (if (> num-configs 1)
        (run-multiplot "plot" configs)
        (run-plot "plot" (. configs 1)))))

(fn splot [...]
  "Accepts one or more splot configurations for multiplot."
  (let [configs [...]
        num-configs (length configs)]
    (if (> num-configs 1)
        (run-multiplot "splot" configs)
        (run-plot "splot" (. configs 1)))))

{:plot plot
 :splot splot}
