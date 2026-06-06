# fplot — Developer Documentation

This directory contains developer documentation for the `gh-wiki` branch of
fplot: the LaTeX-to-Markdown pipeline, the pandoc Lua filter system, and the
`texlua` + Fennel integration.

_Documentation generated with the assistance of a large language model.
Reviewed by the maintainer ItsMeForLua --- Andrew D. France._

---

## Contents

| File | Description |
| --- | --- |
| `pandoc/lua-filter-reference.md` | API reference for the `filters/` module system (Google API style) |
| `pandoc/lua-filter-adr.md` | Architecture decisions for the pandoc filter (Nygard ADR style) |
| `texlua/texlua-fennel-adr.md` | Architecture decisions for the `texlua` + Fennel integration (Nygard ADR style) |

---

## Source

- GitHub: [ItsMeForLua/fplot](https://github.com/ItsMeForLua/fplot) — `gh-wiki` branch
- SourceHut: [~itsmeforlua/fplot](https://git.sr.ht/~itsmeforlua/fplot)

---

## Reference Links

### Pandoc
- [Pandoc Lua Filters](https://pandoc.org/lua-filters.html)

### Lua
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/)
  - [Environments and the Global Environment](https://www.lua.org/manual/5.4/manual.html#2.2)
  - [String Manipulation](https://www.lua.org/manual/5.4/manual.html#6.4)
  - [Operating System Facilities](https://www.lua.org/manual/5.4/manual.html#6.9)

### Fennel
- [Fennel General Documentation](https://dev.fennel-lang.org/wiki)
- [Fennel in LuaTeX](https://dev.fennel-lang.org/wiki/Fennel-in-LuaTeX)

### texlua
- [texlua Manual Page](https://www.systutorials.com/linux-manual-page-1-texlua/) _(non-official, uses Lua 5.4)_

### Documentation Standards
- [Michael Nygard's ADR Template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [Google API Reference Comments](https://developers.google.com/style/api-reference-comments)
- [Write the Docs — Beginner's Guide](https://www.writethedocs.org/guide/writing/beginners-guide-to-docs/)