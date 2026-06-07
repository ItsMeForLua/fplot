# ADR-001: Use Single Quotes for Gnuplot File Paths

*This markdown document was generated with the assistance of a large language model. Reviewed by the maintainer --- Andrew D. France.*

**FYR:**

- *Format:* [*Michael Nygard's ADR template*](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions "null")

**Status:** Accepted

**Context:**

`fplot` generates Gnuplot scripts programmatically. Previously, file paths—both for generated temporary data files and user-defined output files—were enclosed in double quotes (`"`).

In Gnuplot, double quotes evaluate C-style escape sequences (e.g., `\t` evaluates to a tab, `\n` to a newline). On Windows environments (such as MSYS2 or native Windows), file paths naturally contain backslashes. When a path like `C:\temp\new_data.dat` was passed in double quotes, Gnuplot interpreted `\t` and `\n` as escapes, completely mangling the file path and causing "Permission denied" or "cannot open file" errors.

**Decision:**

Switch from double quotes (`"`) to single quotes (`'`) for all file paths injected into Gnuplot scripts. In Gnuplot, single quotes treat the enclosed text as a strict literal.

Specifically, this applies to:

1. `dataset->plot-clause` (for plotting data files)
  
2. The `:output-file` case in `option->cmd` (for setting the output destination)
  

```
;; Before — Windows paths mangled by escape sequences
(.. "set output \"" v "\"\n")
(var clause (.. "\"" filename "\"" ...))

;; After — Windows paths treated as literals
(.. "set output '" v "'\n")
(var clause (.. "'" filename "'" ...))
```

**Consequences:**

- Windows paths are now handled safely and are no longer corrupted by Gnuplot's string parser.
  
- Double quotes are intentionally retained for aesthetic options like `:title`, `:x-label`, and `:labels`. This preserves the user's ability to intentionally use `\n` for multi-line text in plot titles.