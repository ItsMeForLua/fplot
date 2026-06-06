# fplot GitHub Wiki: Source Branch

This is the source branch (`gh-wiki`) for fplot's GitHub wiki pages.
In this branch you can find:

- The LaTeX source files for the wiki pages (`tex/`)
- The compiled PDF (`tex/fplot_wiki.pdf`)
- The transpiled Markdown files that the GitHub wiki sources from (`wiki/`)
- The pandoc Lua filter system that handles the LaTeX → GFM conversion (`filters/`)
- Developer documentation for the pipeline (`dev/`)

_n.b.,_ The code for fplot itself is licensed under **LGPL-3.0**, however, the
fennel code in this branch (`gh-wiki`) that is used for pandoc's AST parser (in
the `/filters` subdirectory) was made with significant assistance from a large
language model, and thus, is public domain — licensed under the Unlicense. For
more information regarding the Unlicense, please refer to the license
declaration appended top-level in each `filters/*.fnl` file.
> There some other .fnl files outside of the `/filters` subdirectory which are simply grandfathered under the fplot license. Code which does not fit the criteria for the Unlicense, given the previously stated conditions.

---

## Pipeline

The wiki pages are generated from a single LaTeX source file via the following
stages:

```
tex/fplot_wiki.tex
    │
    ├── lualatex ──────────────────► tex/fplot_wiki.pdf
    │
    └── split_tex.fnl ─────────────► tex/01_*.tex, tex/02_*.tex, ...
                                           │
                                           └── pandoc + filters/ ──► wiki/01_*.md, wiki/02_*.md, ...
```

---

## Usage

All pipeline stages are driven by the `Makefile`. The main targets are:

| Target | Description |
| --- | --- |
| `make auto-run FILE=tex/fplot_wiki.tex` | Full pipeline: clean, split, compile, build wiki |
| `make split-tex FILE=tex/fplot_wiki.tex` | Split LaTeX source into per-section chunk files |
| `make compile-pdf` | Compile `fplot_wiki.tex` to PDF via lualatex |
| `make build-wiki` | Convert chunk `.tex` files to GFM via pandoc |
| `make clean-all-include-wiki` | Remove all generated artifacts including wiki pages |
| `make clean-all-exclude-wiki` | Remove all generated artifacts, keep wiki pages |

---

## Structure

```
.
├── dev/                    ← developer documentation
│   ├── README.md
│   ├── pandoc/
│   │   ├── lua-filter-reference.md
│   │   └── lua-filter-adr.md
│   └── texlua/
│       └── texlua-fennel-adr.md
├── filters/                ← pandoc Lua filter system
│   ├── lua-filter.lua      ← entry point (Lua)
│   ├── helpers.fnl
│   ├── RawBlock.fnl
│   ├── RawInline.fnl
│   ├── Para.fnl
│   ├── Div.fnl
│   ├── CodeBlock.fnl
│   ├── DefinitionList.fnl
│   └── fennel-1.6.1.lua
├── tex/                    ← LaTeX source and compiled PDF
│   ├── fplot_wiki.tex
│   └── fplot_wiki.pdf
├── wiki/                   ← generated GFM pages (pandoc output)
├── run_split.lua           ← texlua shim for split_tex.fnl
├── split_tex.fnl           ← splits fplot_wiki.tex into per-section chunks
└── Makefile
```

---

## Source

- GitHub: [ItsMeForLua/fplot](https://github.com/ItsMeForLua/fplot) — `gh-wiki` branch
- SourceHut: [~itsmeforlua/fplot](https://git.sr.ht/~itsmeforlua/fplot)