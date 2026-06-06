;; DefinitionList.fnl
;; Transforms native DefinitionList nodes into Markdown friendly tags

{:DefinitionList
 (fn [el]
   (let [result []]
     (each [_ item (ipairs el.content)]
       (let [term (. item 1)
             def-lists (. item 2)]
         (table.insert result (pandoc.Para [(pandoc.Strong term)]))
         (each [_ def-blocks (ipairs def-lists)]
           (each [_ block (ipairs def-blocks)]
             (table.insert result block)))))
     result))}