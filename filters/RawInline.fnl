;; RawInline.fnl
;; Catches inline commands Pandoc passes through as raw

{:RawInline
 (fn [el]
   (if (not= el.format "latex")
       nil

       ;; \code{...}
       (el.text:match "\\code%s*%{(.-)%}")
       (pandoc.Code (el.text:match "\\code%s*%{(.-)%}"))

       ;; \term{...}
       (el.text:match "\\term%s*%{(.-)%}")
       (pandoc.Emph [(pandoc.Str (el.text:match "\\term%s*%{(.-)%}"))])

       ;; \pattern{...}
       (el.text:match "\\pattern%s*%{(.-)%}")
       (pandoc.Strong [(pandoc.Str (el.text:match "\\pattern%s*%{(.-)%}"))])

       ;; \multicomment{...}
       (el.text:match "\\multicomment%s*%b{}")
       (pandoc.Str "")

       nil))}