;; helpers.fnl
;; Shared utility functions loaded into the global scope 
;; so all other handler modules can access them.

(global callout_blockquote
  (fn [label content-blocks]
    (let [header (pandoc.Para [(pandoc.Strong [(pandoc.Str label)])])
          inner [header]]
      (each [_ b (ipairs content-blocks)]
        (table.insert inner b))
      (pandoc.BlockQuote inner))))

(global get_option
  (fn [opts key]
    (if opts
        (let [v (opts:match (.. key "%s*=%s*(%b{})"))]
          (if v
              (v:sub 2 -2)
              (let [v2 (opts:match (.. key "%s*=%s*([^,}%]]+)"))]
                (if v2
                    (v2:match "^%s*(.-)%s*$")
                    nil))))
        nil)))

(local STYLE_TO_LANG {
  :lua "lua"
  :python "python"
  :bash "bash"
  :lisp "lisp"
})

(local LANG_TO_TAG {
  :lua "lua"
  "[5.0]lua" "lua"
  :python "python"
  :bash "bash"
  :lisp "lisp"
})

(global resolve_lang
  (fn [style language]
    (var result "")
    (when style
      (let [s (. STYLE_TO_LANG (-> style (: :lower) (: :match "^%s*(.-)%s*$")))]
        (when s (set result s))))
    (when (and (= result "") language)
      (let [l (. LANG_TO_TAG (-> language (: :lower) (: :match "^%s*(.-)%s*$")))]
        (when l (set result l))))
    result))