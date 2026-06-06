;; RawBlock.fnl
;; Catches \begin{env}...\end{env} blocks that Pandoc couldn't parse

{:RawBlock
 (fn [el]
   (if (not= el.format "latex")
       nil

       ;; multicomment
       (el.text:match "\\multicomment%s*%b{}")
       []

       ;; warningbox
       (el.text:match "\\begin%s*%{warningbox%}")
       (let [inner (el.text:match "\\begin%s*%{warningbox%}(.-)\\end%s*%{warningbox%}")]
         (if inner
             (callout_blockquote "⚠️ Warning" (. (pandoc.read inner "latex") :blocks))))

       ;; notebox
       (el.text:match "\\begin%s*%{notebox%}")
       (let [inner (el.text:match "\\begin%s*%{notebox%}(.-)\\end%s*%{notebox%}")]
         (if inner
             (callout_blockquote "ℹ️ Note" (. (pandoc.read inner "latex") :blocks))))

       ;; dangerbox
       (el.text:match "\\begin%s*%{dangerbox%}")
       (let [inner (el.text:match "\\begin%s*%{dangerbox%}(.-)\\end%s*%{dangerbox%}")]
         (if inner
             (callout_blockquote "🚨 Danger" (. (pandoc.read inner "latex") :blocks))))

       ;; bugentry
       (el.text:match "\\begin%s*%{bugentry%}")
       (let [(title phase severity) (el.text:match "\\begin%s*%{bugentry%}%s*%{(.-)%}%s*%{(.-)%}%s*%{(.-)%}")
             inner (el.text:match "\\begin%s*%{bugentry%}%s*%b{}%s*%b{}%s*%b{}(.-)\\end%s*%{bugentry%}")
             parsed-blocks (if inner (. (pandoc.read inner "latex") :blocks) [])
             heading-text (.. (or title "Bug") "  —  Phase: " (or phase "?") "  ·  Severity: " (or severity "?"))
             result [(pandoc.Header 4 [(pandoc.Str heading-text)])]]
         (each [_ b (ipairs parsed-blocks)]
           (table.insert result b))
         result)

       ;; lispcode
       (el.text:match "\\begin%s*%{lispcode%}")
       (let [code (el.text:match "\\begin%s*%{lispcode%}(.-)\\end%s*%{lispcode%}")]
         (if code
             (pandoc.CodeBlock (code:match "^%s*(.-)%s*$") {:class "lisp"})))

       ;; bashcode
       (el.text:match "\\begin%s*%{bashcode%}")
       (let [code (el.text:match "\\begin%s*%{bashcode%}(.-)\\end%s*%{bashcode%}")]
         (if code
             (pandoc.CodeBlock (code:match "^%s*(.-)%s*$") {:class "bash"})))

       ;; lstlisting
       (el.text:match "\\begin%s*%{lstlisting%}")
       (let [opts (el.text:match "\\begin%s*%{lstlisting%}%s*%[(.-)%]")
             code (or (el.text:match "\\begin%s*%{lstlisting%}.-\n(.-)\\end%s*%{lstlisting%}")
                      (el.text:match "\\begin%s*%{lstlisting%}%s*(.-)%s*\\end%s*%{lstlisting%}"))]
         (if code
             (let [style (if opts (get_option opts "style") nil)
                   language (if opts (get_option opts "language") nil)
                   lang (resolve_lang style language)
                   caption (if opts (get_option opts "caption") nil)
                   cb (pandoc.CodeBlock code {:class lang})]
               (if (and caption (not= caption ""))
                   [(pandoc.Para [(pandoc.Emph [(pandoc.Str caption)])]) cb]
                   cb))))
       
       ;; Fallback to doing nothing
       nil))}