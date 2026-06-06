{:CodeBlock
 (fn [el]
   (if (> (length el.classes) 0)
       (let [cls (. el.classes 1)
             normalised (resolve_lang cls cls)]
         (if (and normalised (not= normalised "") (not= normalised cls))
             (do
               (tset el.classes 1 normalised)
               el)
             nil))
       (let [style (or (. el.attributes "style") "")
             language (or (. el.attributes "language") "")
             lang (resolve_lang style language)]
         (if (and lang (not= lang ""))
             (do
               ;; Explicitly assign the class array rather than inserting
               (set el.classes [lang])
               el)
             nil))))}