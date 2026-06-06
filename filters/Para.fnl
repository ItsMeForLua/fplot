;; Para.fnl
;; Catches \customitem{label}{body} which Pandoc emits as a Para

{:Para
 (fn [el]
   (var raw-text "")
   (var has-raw false)
   
   (each [_ inline (ipairs el.content)]
     (when (and (= inline.t "RawInline") (= inline.format "latex"))
       (set raw-text (.. raw-text inline.text))
       (set has-raw true)))
       
   (if has-raw
       (let [(label body) (raw-text:match "\\customitem%s*%{(.-)%}%s*%{(.-)%}")]
         (if label
             (let [label-inline (pandoc.Strong [(pandoc.Str label)])
                   body-parsed (pandoc.read body "latex")
                   body-inlines []
                   result [(pandoc.Para [label-inline])]]
               (each [_ b (ipairs body-parsed.blocks)]
                 (when (= b.t "Para")
                   (each [_ i (ipairs b.content)]
                     (table.insert body-inlines i))))
               (when (> (length body-inlines) 0)
                 (table.insert result (pandoc.Para body-inlines)))
               result)
             nil))
       nil))}