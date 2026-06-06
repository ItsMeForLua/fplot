# Pandoc LaTeX → GFM Filter: Developer Reference

_This markdown document was generated with the assistance of a large language model. Reviewed by the maintainer ItsMeForLua --- Andrew D. France against pandoc documentation and relevant forums._

**NB:** I do plan on rewriting all of this in my own words (because this is something I want to learn), but for now I'm being strategic with my time.

**FYR:**
- The documentation for Pandoc Lua Filters can be found [here](https://pandoc.org/lua-filters.html).
- _Style: [Google API reference comments](https://developers.google.com/style/api-reference-comments)_

---

Reference for the `filters/` system used to convert LaTeX documentation to
GitHub Flavored Markdown via pandoc.

---

## How Pandoc Processes a Document

Pandoc's conversion pipeline has three stages:

```
Input file  →  [Reader]  →  AST  →  [Lua Filter]  →  [Writer]  →  Output file
```

1. **Reader** parses the input format (LaTeX in our case) into an internal
   Abstract Syntax Tree (AST) — a structured tree of typed nodes like `Para`,
   `Header`, `CodeBlock`, `BulletList`, `Div`, `RawBlock`, etc.
2. **Lua filters** walk the AST and transform nodes before output.
3. **Writer** serialises the modified AST into the target format (GFM).

The critical implication: **the filter never sees raw LaTeX text directly**.
It sees whatever the reader decided to produce. If the reader drops information
(like `\item[label]` content when it encounters unknown `enumitem` options), the
filter has nothing to recover — that data is simply gone.

This is why inspecting the AST is essential before writing any handler, and why
LaTeX source compatibility matters.

### Inspecting the AST

When something isn't converting correctly, always check the AST first:

```bash
pandoc input.tex -f latex -t native > ast.txt
```

This dumps pandoc's internal representation. The output looks like:

```
[ Para
    [ Str "Some text" ]
, CodeBlock ( "" , [] , [ ( "style" , "lua" ) ] )
    "local x = 1"
, Div ( "" , [ "warningbox" ] , [] )
    [ Para [ Str "Watch out!" ] ]
]
```

Match your handler to the node type you actually see, not what you expect.
The AST is the ground truth.

---

## File Layout

```
filters/
  lua-filter.lua      ← entry point (the only file pandoc is pointed at)
  helpers.fnl         ← shared utility functions, loaded first
  RawBlock.fnl        ← \begin{env}...\end{env} pandoc could not parse
  RawInline.fnl       ← inline commands (\code, \term, \pattern, \multicomment)
  Para.fnl            ← \customitem{}{} embedded in paragraphs
  Div.fnl             ← environments pandoc partially parsed into a Div node
  CodeBlock.fnl       ← fix language tags on already-parsed code blocks
  DefinitionList.fnl  ← \begin{description} parsed natively; labels rescued
```

Run with:

```bash
pandoc input.tex -f latex -t gfm --lua-filter=filters/lua-filter.lua -o output.md
```

---

## Writing Pandoc Lua Filters

### The core concept

A Lua filter is a script that defines functions named after pandoc AST node
types. Pandoc calls each function automatically when it walks the tree and
encounters a matching node. The function receives the node as its argument
and can return:

- A **replacement node** (or list of nodes) — pandoc swaps it in
- `nil` — pandoc leaves the node untouched
- `{}` (empty list) — pandoc deletes the node entirely

```lua
-- The simplest possible filter: delete every horizontal rule
function HorizontalRule(el)
  return {}   -- returning empty list removes the node
end

-- Convert every emphasis to strong
function Emph(el)
  return pandoc.Strong(el.content)  -- return a replacement node
end

-- Leave everything else alone
function Para(el)
  return nil  -- nil = do nothing
end
```

### Traversal order

Within a single filter, pandoc processes element types in a fixed sequence
regardless of the order handlers are defined. The default **typewise** traversal
runs:

1. Inline element handlers (`RawInline`, `Str`, `Emph`, `Code`, …)
2. The special `Inlines` list handler (if defined)
3. Block element handlers (`RawBlock`, `Para`, `Div`, `CodeBlock`, `DefinitionList`, …)
4. The special `Blocks` list handler (if defined)
5. `Meta`
6. `Pandoc`

The practical consequence for this filter: **`RawInline` handlers always run
before `RawBlock` handlers**, regardless of which `fennel.dofile` line comes
first in `lua-filter.lua`. For this filter that is expected and harmless, since
inline and block environments are independent. Be aware of the order if you ever
write a handler whose input depends on the output of another handler in the same
pass.

See the [traversal order docs](https://pandoc.org/lua-filters.html#traversal-order)
for details and for the `topdown` alternative.

### Node types

These are the node types relevant to LaTeX conversion. Check the AST with
`-t native` to confirm which one pandoc produces for a given construct.

| Node type | When pandoc produces it |
| --- | --- |
| `RawBlock` | A block-level construct pandoc could not parse at all |
| `RawInline` | An inline command pandoc could not parse |
| `Div` | A block pandoc partially parsed; wraps content with a class name |
| `CodeBlock` | A verbatim/lstlisting block pandoc did parse |
| `DefinitionList` | A `description` environment pandoc parsed natively |
| `Para` | A paragraph, possibly containing `RawInline` nodes |
| `BulletList` | `\begin{itemize}` |
| `OrderedList` | `\begin{enumerate}` |
| `BlockQuote` | `\begin{quote}` |
| `Header` | `\section`, `\subsection`, etc. |

### Pandoc node constructors

Pandoc provides a `pandoc.*` constructor for every node type. The first
argument is almost always a list of child nodes (inlines or blocks).
`pandoc.Str` wraps a plain string as an inline.

```lua
pandoc.Para({ pandoc.Str("Hello") })
pandoc.Strong({ pandoc.Str("bold text") })
pandoc.Emph({ pandoc.Str("italic text") })
pandoc.Code("inline code")
pandoc.CodeBlock("code content", { class = "lua" })
pandoc.Header(2, { pandoc.Str("A heading") })
pandoc.BlockQuote({ pandoc.Para({ pandoc.Str("quoted") }) })
```

**Attr shorthand:** wherever a constructor takes element attributes, pandoc
accepts an HTML-like table as shorthand for `pandoc.Attr`. Both of the
following are equivalent:

```lua
pandoc.CodeBlock("code content", { class = "lua" })
pandoc.CodeBlock("code content", pandoc.Attr("", { "lua" }))
```

See [pandoc.org/lua-filters.html#type-attr](https://pandoc.org/lua-filters.html#type-attr).

### Re-parsing inner content

Use `pandoc.read` to properly parse extracted LaTeX text rather than emitting
it as a plain string. `pandoc.read` returns a `Pandoc` document object;
`.blocks` gives the list of top-level block nodes.

```lua
local inner = raw:match("\\begin%s*%{myenv%}(.-)\\end%s*%{myenv%}")
local parsed = pandoc.read(inner, "latex")
return pandoc.BlockQuote(parsed.blocks)
```

### Lua pattern matching for LaTeX

| Pattern | Matches |
| --- | --- |
| `\\begin%s*%{warningbox%}` | `\begin{warningbox}` with optional spaces |
| `(.-)` | Shortest match (lazy) — use for content between tags |
| `%b{}` | Balanced braces — safe for nested `{...}` |
| `^%s*(.-)%s*$` | Trim leading and trailing whitespace |

`%b{}` is especially important for LaTeX because arguments can contain nested
braces. A naive `{(.-)}` stops at the first `}`.

> **Heads-up — locale-dependent pattern matching:** Lua character classes like
> `%a` and `%p` depend on the current locale. For portable filters, add
> `os.setlocale 'C'` at the top of `lua-filter.lua`. See the
> [common pitfalls section](https://pandoc.org/lua-filters.html#common-pitfalls)
> of the official docs.

---

## Module Reference

### `lua-filter.lua`

Entry point. Loads the Fennel compiler, executes `helpers.fnl` to expose shared
globals, loads each handler module, merges their returned tables into a single
filter table, and returns it to pandoc.

This is the only file pandoc is pointed at directly. All handler logic lives in
the `.fnl` files.

```lua
local root = pandoc.path.directory(PANDOC_SCRIPT_FILE)
local fennel = dofile(root .. "/fennel-1.6.1.lua")
table.insert(package.searchers or package.loaders, fennel.searcher)

fennel.dofile(root .. "/helpers.fnl")

local modules = {
  fennel.dofile(root .. "/RawBlock.fnl"),
  fennel.dofile(root .. "/RawInline.fnl"),
  fennel.dofile(root .. "/Para.fnl"),
  fennel.dofile(root .. "/Div.fnl"),
  fennel.dofile(root .. "/CodeBlock.fnl"),
  fennel.dofile(root .. "/DefinitionList.fnl")
}

local filter = {}
for _, mod in ipairs(modules) do
  for k, v in pairs(mod) do filter[k] = v end
end

return filter
```

`PANDOC_SCRIPT_FILE` is a pandoc global containing the path used to invoke the
filter. `pandoc.path.directory()` strips the filename, giving the containing
folder, so the entire `filters/` directory can be moved anywhere without
breaking paths.

> **Note on returning a list of filters:** the docs mention that a script can
> return a list of filter tables to run multiple sequential passes. This is now
> **discouraged** — use the
> [`:walk`](https://pandoc.org/lua-filters.html#type-pandoc:walk) method for
> multi-pass transforms instead.

---

### `helpers.fnl`

Shared utility functions exposed as globals via `global`. Must be loaded before
any handler module, since all handlers call these functions directly.

---

#### `callout_blockquote(label, content-blocks)`

Wraps a list of blocks in a GFM blockquote with a bold label header.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `label` | string | The text to display as the bold header. For example, `"⚠️ Warning"`. |
| `content-blocks` | list of pandoc block nodes | The body content to place inside the blockquote. |

**Returns:** A `pandoc.BlockQuote` containing a bold label paragraph followed
by `content-blocks`.

```fennel
(callout_blockquote "⚠️ Warning" (. (pandoc.read inner "latex") :blocks))
```

---

#### `get_option(opts, key)`

Extracts a named value from a LaTeX options string.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `opts` | string or nil | The raw options string, e.g. `"style=lua, caption={My caption}"`. If `nil`, returns `nil` immediately. |
| `key` | string | The option name to look up, e.g. `"style"` or `"caption"`. |

**Returns:** The value as a string with surrounding braces stripped, or `nil`
if the key is not found. Handles both `{braced}` values and bare values.

```fennel
(get_option opts "style")    ;; => "lua"
(get_option opts "caption")  ;; => "My caption"
(get_option nil  "style")    ;; => nil
```

---

#### `resolve_lang(style, language)`

Resolves a GFM fence language tag from a lstlisting `style` or `language` value.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `style` | string or nil | The `style=` value from a lstlisting options string. Checked first. |
| `language` | string or nil | The `language=` value from a lstlisting options string. Checked if `style` does not resolve. |

**Returns:** A language tag string such as `"lua"`, `"python"`, or `"bash"`, or
`""` if neither argument matches a known entry in `STYLE_TO_LANG` or
`LANG_TO_TAG`.

To add a new language, add it to both `STYLE_TO_LANG` and `LANG_TO_TAG` in
`helpers.fnl`. `STYLE_TO_LANG` maps custom `lstdefinestyle` names;
`LANG_TO_TAG` maps pandoc's `language=` values.

```fennel
(resolve_lang "lua" nil)      ;; => "lua"
(resolve_lang nil "python")   ;; => "python"
(resolve_lang nil nil)        ;; => ""
```

---

### `RawBlock.fnl`

Converts unparsed LaTeX block environments into GFM equivalents. Handles
`\multicomment{}`, callout boxes (`warningbox`, `notebox`, `dangerbox`),
`bugentry`, named code environments (`lispcode`, `bashcode`), and
`\begin{lstlisting}`.

---

#### `RawBlock(el)`

Converts a `RawBlock` node containing raw LaTeX into the appropriate GFM
structure.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `RawBlock` | The raw block node. Relevant fields: `el.format` (string) and `el.text` (string). |

**Returns**

| Condition | Return value |
| --- | --- |
| `el.format` is not `"latex"` | `nil` — node is left untouched |
| `\multicomment{}` matched | `[]` — node is deleted |
| `warningbox`, `notebox`, or `dangerbox` matched | `pandoc.BlockQuote` with emoji label |
| `bugentry` matched | List: `pandoc.Header(4)` + body blocks |
| `lispcode` or `bashcode` matched | `pandoc.CodeBlock` with language class |
| `lstlisting` matched | `pandoc.CodeBlock`, optionally preceded by a caption `pandoc.Para` |
| No pattern matches | `nil` — node is left untouched |

```fennel
;; warningbox example
(el.text:match "\\begin%s*%{warningbox%}")
(let [inner (el.text:match "\\begin%s*%{warningbox%}(.-)\\end%s*%{warningbox%}")]
  (if inner
      (callout_blockquote "⚠️ Warning" (. (pandoc.read inner "latex") :blocks))))
```

---

### `RawInline.fnl`

Converts unparsed LaTeX inline commands into GFM equivalents. Handles
`\code{}`, `\term{}`, `\pattern{}`, and `\multicomment{}`.

---

#### `RawInline(el)`

Converts a `RawInline` node containing a raw LaTeX command into the appropriate
inline node.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `RawInline` | The raw inline node. Relevant fields: `el.format` (string) and `el.text` (string). |

**Returns**

| Condition | Return value |
| --- | --- |
| `el.format` is not `"latex"` | `nil` — node is left untouched |
| `\code{...}` matched | `pandoc.Code` |
| `\term{...}` matched | `pandoc.Emph` wrapping a `pandoc.Str` |
| `\pattern{...}` matched | `pandoc.Strong` wrapping a `pandoc.Str` |
| `\multicomment{...}` matched | `pandoc.Str("")` — effectively deleted |
| No pattern matches | `nil` — node is left untouched |

```fennel
(el.text:match "\\code%s*%{(.-)%}")
(pandoc.Code (el.text:match "\\code%s*%{(.-)%}"))
```

---

### `Para.fnl`

Converts `\customitem{label}{body}` commands into a bold label paragraph
followed by body content. Handles the case where pandoc emits the command as a
`Para` containing `RawInline` nodes.

---

#### `Para(el)`

Scans a `Para` node for raw LaTeX, pattern-matches for `\customitem`, and
rebuilds the output as structured blocks.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `Para` | The paragraph node. Relevant field: `el.content` (list of inline nodes). |

**Returns**

| Condition | Return value |
| --- | --- |
| No `RawInline` nodes present | `nil` — node is left untouched |
| `\customitem` not matched | `nil` — node is left untouched |
| `\customitem{label}{body}` matched | List: bold label `pandoc.Para` + parsed body blocks |

**Note:** Only `RawInline` nodes are concatenated when scanning. Any non-raw
inlines in the same paragraph are silently ignored. For `\customitem` this is
safe because the entire paragraph is the raw command.

```fennel
(let [(label body) (raw-text:match "\\customitem%s*%{(.-)%}%s*%{(.-)%}")]
  (if label
      [(pandoc.Para [(pandoc.Strong [(pandoc.Str label)])])
       ...body blocks...]))
```

---

### `Div.fnl`

Converts partially-parsed LaTeX environments wrapped in a `Div` into GFM
equivalents. Acts as a fallback for environments that `RawBlock.fnl` does not
catch because pandoc partially parsed them.

Handles callout boxes (`warningbox`, `notebox`, `dangerbox`), `bugentry`,
`blockquote`, `center`, and `description`.

---

#### `Div(el)`

Checks the class list of a `Div` node and converts it to the appropriate GFM
structure.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `Div` | The div node. Relevant fields: `el.classes` (list), `el.attributes` (table), `el.content` (list of block nodes). |

**Returns**

| Condition | Return value |
| --- | --- |
| Class is `warningbox`, `notebox`, or `dangerbox` | `pandoc.BlockQuote` with emoji label via `callout_blockquote` |
| Class is `bugentry` | List: `pandoc.Header(4)` + body blocks |
| Class is `blockquote` | `pandoc.BlockQuote` wrapping `el.content` |
| Class is `center` | `el.content` unwrapped (centering is meaningless in Markdown) |
| No class matches | `nil` — node is left untouched |

```fennel
(each [env label (pairs DIV_MAP)]
  (when (el.classes:includes env)
    (set matched (callout_blockquote label el.content))))
```

---

### `CodeBlock.fnl`

Promotes a language identifier from a `CodeBlock` node's attributes into its
class list, enabling GFM syntax highlighting.

Pandoc stores `[style=lua]` from `\lstlisting[style=lua]` as a key-value
attribute, not as a class. Without this handler, all fenced code blocks in the
output have no language tag.

**Note:** This handler runs only on `CodeBlock` nodes pandoc produced natively.
`CodeBlock` nodes created inside `RawBlock.fnl` bypass this handler entirely —
which is why `RawBlock.fnl` sets the class directly at construction time.

---

#### `CodeBlock(el)`

Normalises or inserts a language class on a `CodeBlock` node.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `CodeBlock` | The code block node. Relevant fields: `el.classes` (list) and `el.attributes` (table). |

**Returns**

| Condition | Return value |
| --- | --- |
| Class already set and resolves to a different normalised value | Modified `el` with `el.classes[1]` updated |
| Class already set and is already normalised | `nil` — node is left untouched |
| No class; `style` or `language` attribute resolves to a known language | Modified `el` with `el.classes` set to `[lang]` |
| No class; no attribute resolves | `nil` — node is left untouched |

```fennel
;; Case: style in attributes
(let [style    (or (. el.attributes "style") "")
      language (or (. el.attributes "language") "")
      lang     (resolve_lang style language)]
  (if (and lang (not= lang ""))
      (do (set el.classes [lang]) el)
      nil))
```

---

### `DefinitionList.fnl`

Converts a `DefinitionList` node into bold label paragraphs followed by
definition bodies, rescuing term labels that the GFM writer would otherwise
silently drop.

`\begin{description}` is parsed natively by pandoc into a `DefinitionList`
node, so it never reaches `RawBlock` or `Div`. The GFM writer has no definition
list syntax and silently drops the terms without this handler.

---

#### `DefinitionList(el)`

Converts each `(term, definition)` pair in a `DefinitionList` into a bold
paragraph followed by the definition body.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `el` | pandoc `DefinitionList` | The definition list node. Relevant field: `el.content` (list of `[term, definitions]` pairs). |

**Returns:** A flat list of block nodes alternating between bold label
paragraphs (`pandoc.Para` wrapping `pandoc.Strong`) and definition body blocks.

```fennel
(each [_ item (ipairs el.content)]
  (let [term      (. item 1)
        def-lists (. item 2)]
    (table.insert result (pandoc.Para [(pandoc.Strong term)]))
    (each [_ def-blocks (ipairs def-lists)]
      (each [_ block (ipairs def-blocks)]
        (table.insert result block)))))
```

---

## LaTeX Compatibility Rules (Required)

Hard requirements. These are not style suggestions — breaking them produces
wrong output the filter cannot fix.

### Lists

Never use `\begin{description}` with `enumitem` options:

```latex
% Labels will be dropped by pandoc's reader — unrecoverable
\begin{description}[style=nextline, leftmargin=2em]
  \item[\textbf{Label:}] Body.
\end{description}

% Use this instead
\begin{itemize}
  \item \textbf{Label:} Body.
\end{itemize}
```

Plain `\begin{description}` without options is handled by `DefinitionList.fnl`,
but `\begin{itemize}` is preferred for reliability.

### Code blocks

Always tag code blocks with a style. Untagged blocks produce `CodeBlock` nodes
with no language information and the filter cannot determine the language.

Write code content flush to the left margin inside `lstlisting`:

```latex
% This indent carries into the output
\begin{lstlisting}[style=lua]
    local x = 1
\end{lstlisting}

% Correct
\begin{lstlisting}[style=lua]
local x = 1
\end{lstlisting}
```

When adding a new `lstdefinestyle`, add it to `STYLE_TO_LANG` in `helpers.fnl`.

### Inline commands

`\code{}`, `\term{}`, `\pattern{}` are handled by `RawInline.fnl`. Any other
custom inline commands pass through as raw LaTeX and appear literally in the
output. Add new ones to `RawInline.fnl`.

### Environments that work without the filter

Pandoc handles these natively:

- `\begin{itemize}` / `\begin{enumerate}` → bullet/numbered lists
- `\begin{quote}` → GFM blockquote
- `\section`, `\subsection`, etc. → headings
- `\textbf{}`, `\emph{}`, `\textit{}` → bold / italic
- `\texttt{}` → inline code
- `\href{}{}` → links
- `\begin{tabular}` → markdown table (simple tables only)

### Environments that require the filter

These will fail without the matching handler in `filters/`:

- `warningbox`, `notebox`, `dangerbox` → GFM blockquotes with labels
- `bugentry{}{}{}` → `####` heading + body
- `lispcode`, `bashcode` → fenced code with language tag
- `\lstlisting[style=...]` → fenced code with language tag
- `\customitem{}{}` → bold label + body
- `\multicomment{}` → deleted

---

## Adding a New Custom Environment

1. Run `pandoc input.tex -f latex -t native > ast.txt` and find the node type
   pandoc produces for your environment.
2. Pick the right handler file:
   - Node is `RawBlock` → add to `RawBlock.fnl`
   - Node is `Div` with a class → add to `Div.fnl`
   - Node is `RawInline` inside a `Para` → add to `Para.fnl`
   - It is a natively-parsed node type → create a new `.fnl` file named after it
3. Add a handler block following the existing patterns.
4. If it involves a new code language, add it to `STYLE_TO_LANG` and
   `LANG_TO_TAG` in `helpers.fnl`.
5. If it is a new file, add a `fennel.dofile` line for it in `lua-filter.lua`
   and include it in the `modules` table.