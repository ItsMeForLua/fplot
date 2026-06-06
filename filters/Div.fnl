;; Div.fnl
;; Catch unknown environments Pandoc wrapped in a Div as a fallback

(local DIV_MAP {
  :warningbox "⚠️ Warning"
  :notebox "ℹ️ Note"
  :dangerbox "🚨 Danger"
})

{:Div
 (fn [el]
   (var matched nil)
   (each [env label (pairs DIV_MAP)]
     (when (el.classes:includes env)
       (set matched (callout_blockquote label el.content))))

   (if matched
       matched

       ;; bugentry
       (el.classes:includes "bugentry")
       (let [title (or (. el.attributes "title") "Bug")
             phase (or (. el.attributes "phase") "?")
             severity (or (. el.attributes "severity") "?")
             heading (pandoc.Header 4 [(pandoc.Str (.. title "  —  Phase: " phase "  ·  Severity: " severity))])
             result [heading]]
         (each [_ b (ipairs el.content)]
           (table.insert result b))
         result)

       ;; blockquote
       (el.classes:includes "blockquote")
       (pandoc.BlockQuote el.content)

       ;; center
       (el.classes:includes "center")
       el.content

       ;; description
       (el.classes:includes "description")
       (let [items []]
         (var current-label nil)
         (var current-body [])
         
         (fn flush []
           (when current-label
             (table.insert items [current-label [current-body]])
             (set current-label nil)
             (set current-body [])))
             
         (each [_ block (ipairs el.content)]
           (if (= block.t "Para")
               (let [first (. block.content 1)]
                 (if (and first (= first.t "Strong"))
                     (do
                       (flush)
                       (set current-label first.content)
                       (let [rest []]
                         (for [i 2 (length block.content)]
                           (table.insert rest (. block.content i)))
                         (when (> (length rest) 0)
                           (table.insert current-body (pandoc.Para rest)))))
                     (table.insert current-body block)))
               (table.insert current-body block)))
         (flush)
         
         (if (> (length items) 0)
             (pandoc.DefinitionList items)
             el.content))

       nil))}