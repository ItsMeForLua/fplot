# Pandoc LaTeX → GFM Filter: Architecture Decision Records

_This markdown document was generated with the assistance of a large language model. Reviewed by the maintainer ItsMeForLua --- Andrew D. France against pandoc documentation and relevant forums._

**NB:** I do plan on rewriting all of this in my own words (because this is something I want to learn), but for now I'm being strategic with my time.

**FYR:**
- The documentation for Pandoc Lua Filters can be found [here](https://pandoc.org/lua-filters.html).
- _Format: [Michael Nygard's ADR template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)_

---

A record of decisions made during the development of the `filters/` system used
to convert LaTeX documentation to GitHub Flavored Markdown via pandoc.

---

## ADR-001: Use `\begin{itemize}` Instead of `\begin{description}` with enumitem Options

**Status:** Accepted

**Context:**

The source LaTeX used `\begin{description}` with `enumitem` options
(`[style=nextline, leftmargin=2em]`) to produce labelled feature lists.
After conversion, all item labels were missing — the output was plain
unlabelled paragraphs with no indication that labels had ever existed.

The root cause is two-part. First, pandoc's LaTeX reader silently drops
`\item[label]` content when it encounters unknown `enumitem` options — the
information is gone before the filter runs and cannot be recovered. Second,
even when pandoc does parse a plain `\begin{description}` correctly into a
`DefinitionList` node, the GFM writer drops the terms because GFM has no
`<dl>` equivalent.

**Decision:**

Replace `\begin{description}` with `\begin{itemize}` in the LaTeX source and
put labels inline using `\textbf{}`:

```latex
% Before — labels silently dropped
\begin{description}[style=nextline, leftmargin=2em]
  \item[\textbf{Label:}] Body text.
\end{description}

% After — pandoc preserves everything
\begin{itemize}
  \item \textbf{Label:} Body text.
\end{itemize}
```

`DefinitionList.fnl` is retained to handle any plain `\begin{description}`
without options that may appear in the source.

**Consequences:**

- Label content is no longer silently lost during conversion.
- The LaTeX source loses the visual formatting benefit of `enumitem` options,
  which is acceptable since the primary output target is Markdown.
- Any future `\begin{description}` usage without `enumitem` options is still
  handled correctly by `DefinitionList.fnl`.
- The constraint must be documented and enforced manually — pandoc gives no
  warning when labels are dropped.

---

## ADR-002: Promote Language Tags from CodeBlock Attributes into Classes

**Status:** Accepted

**Context:**

After conversion, all fenced code blocks in the GFM output had no language
identifier, disabling GitHub syntax highlighting. The source LaTeX used
`\lstlisting[style=lua]` to tag code blocks.

Pandoc stores the `style=lua` option as a key-value **attribute** on the
`CodeBlock` node, not as a class. The AST looks like:

```
CodeBlock ( "" , [] , [ ( "style" , "lua" ) ] ) "..."
--                ^              ^
--            empty classes   attribute
```

The initial handler checked `el.classes[1]`, which is always empty for
natively-parsed `lstlisting` blocks, so the language was never applied.

**Decision:**

Add `CodeBlock.fnl` to check `el.attributes["style"]` and
`el.attributes["language"]`, resolve them to a GFM language tag via
`resolve_lang`, and promote the result into `el.classes`.

`CodeBlock` nodes created inside `RawBlock.fnl` bypass this handler entirely
and set the class directly at construction time — this is intentional.

**Consequences:**

- Natively-parsed `lstlisting` blocks now produce fenced code with correct
  language tags.
- Adding support for a new language requires updating `STYLE_TO_LANG` and
  `LANG_TO_TAG` in `helpers.fnl` — there is no automatic fallthrough.
- The distinction between attribute-stored and class-stored language information
  is a pandoc internal detail that may change across pandoc versions.

---

## ADR-003: Handle Both `RawBlock` and `Div` for the Same Environments

**Status:** Accepted

**Context:**

Custom environments such as `warningbox`, `notebox`, and `dangerbox` were
appearing as raw `<div class="warningbox">` HTML in the GFM output. The
`RawBlock` handler was not firing for these environments.

Pandoc's LaTeX reader is inconsistent: the same custom environment can produce
a `RawBlock` in one document and a `Div` in another, depending on context and
pandoc version. In this case, pandoc recognised the `\begin{}` tag but not the
environment, and wrapped the content in a `Div` with the environment name as a
CSS class. Since the content was not a `RawBlock`, the `RawBlock` handler never
ran.

**Decision:**

Handle both node types for every environment that exhibits this inconsistency:

- `RawBlock.fnl` catches the environment when pandoc could not parse it at all.
- `Div.fnl` catches the environment when pandoc partially parsed it into a `Div`.

Both handlers call `callout_blockquote` from `helpers.fnl` so the output is
identical regardless of which path fired.

**Consequences:**

- All callout box environments are converted correctly regardless of pandoc
  version or document context.
- Each new custom environment must be added to both `RawBlock.fnl` and
  `Div.fnl` — adding to only one is a latent bug.
- The duplication is intentional and should not be consolidated.

---

## ADR-004: Intercept `\customitem` at the `Para` Level

**Status:** Accepted

**Context:**

API reference entries using `\customitem{label}{body}` were disappearing
entirely from the output — no bold labels, no body content.

`\customitem` is a two-argument custom command. Pandoc cannot parse it and
passes it through as a `RawInline` node inside a `Para`. No handler was
intercepting at the `Para` level: `RawInline.fnl` handles single inline
commands, but `\customitem` produces both a label and body that must be
restructured into separate block-level nodes, which `RawInline` cannot do.

**Decision:**

Add `Para.fnl` to intercept at the paragraph level. The handler concatenates
all raw LaTeX text from the paragraph's `RawInline` nodes, pattern-matches for
`\customitem`, and rebuilds the output as a bold label paragraph followed by the
parsed body.

Non-raw inline nodes in the same paragraph are silently ignored. This is
acceptable because `\customitem` always occupies the entire paragraph.

**Consequences:**

- `\customitem` entries are correctly rendered as bold labels followed by body
  content.
- The handler silently ignores non-raw inlines in the same paragraph — if
  `\customitem` is ever mixed with other inline content, that content will be
  lost with no warning.
- Any future multi-argument custom commands that require block-level
  restructuring should follow the same `Para`-level interception pattern.

---

## ADR-005: Write `lstlisting` Content Flush to the Left Margin

**Status:** Accepted

**Context:**

Code blocks in the GFM output had large leading indentation on every line,
making them visually broken and unsuitable for syntax highlighting tools that
are sensitive to indentation (such as Python examples).

The source `lstlisting` content was indented with tabs to match the surrounding
document structure. `lstlisting` preserves whitespace literally — the tabs
inside the environment are treated as content, not structure, and carry directly
into the output.

**Decision:**

Write all `lstlisting` content flush to the left margin in the LaTeX source,
regardless of surrounding indentation level:

```latex
% Before — indentation carries into output
\begin{lstlisting}[style=lua]
    local x = 1
\end{lstlisting}

% After — content flush to left margin
\begin{lstlisting}[style=lua]
local x = 1
\end{lstlisting}
```

This is a LaTeX source authoring constraint, not a filter fix. The filter
cannot strip indentation without risking corruption of intentionally indented
content such as Python or Fennel.

**Consequences:**

- Code block output is correctly formatted with no spurious leading indentation.
- The LaTeX source looks visually inconsistent — `lstlisting` content is not
  indented while surrounding code is. This is a known and accepted trade-off.
- The constraint must be documented and enforced manually at authoring time.