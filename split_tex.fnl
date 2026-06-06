;; n.b., input-filename is injected by run_split.lua via _G before dofile is called.
;; Do not attempt to read this from os.getenv or arg because neither is available here.
;; This should be reading the filename injected by the Lua shim into _G
(local input-filename (or _G.input_filename (error "No input file provided")))
(local output-dir "tex/")

(let [f (io.open input-filename "r")]
  (if (not f)
      (error (.. "Could not open " input-filename ". Make sure you are in the project's root."))
      (let [content (f:read "*all")]
        (f:close)

        (let [(body-start _) (content:find "\\begin{document}")]
          (if (not body-start)
              (error "Could not find \\begin{document} in the source file.")
              (let [body-end (content:find "\\end{document}")
                    body (content:sub body-start (- body-end 1))
                    sections []]

                (each [pos title (body:gmatch "()\\section%s*%{([^}]+)%}")]
                  (table.insert sections {:pos pos :title title}))

                (when (= (length sections) 0)
                  (print "Warning: No \\section{} tags found in the body!"))

                (each [i sec (ipairs sections)]
                  (let [start-pos sec.pos
                        end-pos (if (< i (length sections))
                                    (let [next-sec (. sections (+ i 1))]
                                      (- next-sec.pos 1))
                                    (length body))
                        chunk (body:sub start-pos end-pos)
                        safe-title (-> sec.title
                                       (string.gsub "[^%w%s-]" "")
                                       (string.gsub "%s+" "_"))
                        filename (string.format "%s%02d_%s.tex" output-dir i safe-title)]
                    (print (string.format "Writing %02d/%02d: %s" i (length sections) filename))
                    (let [out (io.open filename "w")]
                      (out:write chunk)
                      (out:close))))

                (print (.. "Splitting complete. Files written to " output-dir))))))))