# texlua + Fennel Integration: Architecture Decision Records

_This markdown document was generated with the assistance of a large language model. Reviewed by the maintainer ItsMeForLua --- Andrew D. France against texlua documentation, Lua 5.4 reference manual, and Fennel source._

_Format: [Michael Nygard's ADR template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)_

**FYR:**
- The documentation for fennel in luatex can be found [here](https://dev.fennel-lang.org/wiki/Fennel-in-LuaTeX).
- The _non-official_ documentation for latest version of texlua (uses lua5.4) that was used for reference can be found [here](https://www.systutorials.com/linux-manual-page-1-texlua/).
- The official lua5.4 documentation can be found [here](https://www.lua.org/manual/5.4/).
    - [Environments and the Global Environment](https://www.lua.org/manual/5.4/manual.html#2.2)
    - [String Manipulation](https://www.lua.org/manual/5.4/manual.html#6.4)
    - [Operating System Facilities](https://www.lua.org/manual/5.4/manual.html#6.9)
- Official general documentation for fennel can be found [here](https://dev.fennel-lang.org/wiki).

---

A record of integration issues encountered when using LuaTeX's standalone Lua
interpreter `texlua` to run Fennel scripts, and the decisions made to resolve
them.

---

## Environment

| Tool | Version | Role |
| --- | --- | --- |
| `texlua` | LuaTeX bundled | Lua interpreter (standalone mode) |
| Fennel | 1.6.1 | Lisp-to-Lua compiler |
| Lua | 5.4 (via LuaTeX) | Runtime |

---

## ADR-001: Use a Loader Script Instead of the `-e` Flag

**Status:** Accepted

**Context:**

The initial approach was to use `texlua -e` to evaluate Lua expressions inline
from a makefile recipe, the same way standard `lua -e` works:

```bash
lua -e "print('hello')"
```

`texlua` does not support `-e`. Passing it causes `texlua` to treat the entire
string as a filename:

```
Script file package.path = package.path .. ';./?.lua' not found
```

`texlua` is LuaTeX acting as a Lua interpreter (`--luaonly` mode). It does not
implement the full standard Lua CLI interface. Its supported flags are:

```
--luaonly      run a lua file, then exit
--luaconly     byte-compile a lua file, then exit
--lua=FILE     load and execute a lua initialization script
```

**Decision:**

Use a small loader `.lua` file instead of inline `-e` strings. All setup that
would have been done via `-e` (path configuration, module loading, script
invocation) is moved into the loader:

```lua
-- run_script.lua
package.path = './?.lua;./subdir/?.lua'
require('my-module').dofile('my-script.fnl')
```

```makefile
run:
	@texlua --luaonly run_script.lua
```

**Consequences:**

- The `-e` approach is permanently unavailable under `texlua`; the loader
  pattern is the only viable path.
- Any setup that would have been a one-liner in a makefile recipe now requires
  a dedicated `.lua` file per script entry point.
- The loader file becomes a natural place to document path configuration and
  module registration, which improves maintainability.

---

## ADR-002: Use `package.preload` to Register Fennel by a Dot-Free Alias

**Status:** Accepted

**Context:**

`require('fennel-1.6.1')` failed with:

```
no file './fennel-1/6/1.lua'
no file './subdir/fennel-1/6/1.lua'
```

The dots in `fennel-1.6.1` were being expanded into path separators. This is
documented Lua behaviour: `package.searchpath` replaces every dot in a module
name with the system directory separator before searching `package.path`.
Hyphens are left alone, but dots are not.

From the Lua 5.4 reference manual:

> `package.searchpath` — For each template, the function replaces each
> interrogation mark (if any) in the template with a copy of name wherein all
> occurrences of `sep` (a dot, by default) were replaced by `rep` (the
> system's directory separator, by default).

A filename like `fennel-1.6.1.lua` therefore cannot be reliably required by
its bare name via `package.path` alone.

**Decision:**

Register the module in `package.preload` under a dot-free alias before calling
`require`. `package.preload` is checked before any path search occurs, so the
dot expansion never happens:

```lua
package.path = './?.lua;./filters/?.lua'

-- Register under a dot-free alias
package.preload['fennel'] = loadfile('./filters/fennel-1.6.1.lua')

require('fennel').dofile('my-script.fnl')
```

Any subsequent `require('fennel')` calls hit the preload cache and return the
already-loaded module without touching the path.

**Consequences:**

- The versioned filename `fennel-1.6.1.lua` can stay as-is; no renaming
  required.
- The alias `'fennel'` must be kept dot-free. If a different alias is ever
  chosen, the same constraint applies.
- Any subsequent `require('fennel')` in the same process returns the cached
  module — the file is not re-executed.
- An alternative would be renaming the file to remove dots entirely
  (`fennel-161.lua`, `fennel_1_6_1.lua`), but this loses the version
  information from the filename and requires updating any external references
  to it.

---

## ADR-003: Bind Table Field Before Arithmetic in Fennel

**Status:** Accepted

**Context:**

The following Fennel expression caused a runtime error:

```fennel
(- (. sections (+ i 1)) :pos 1)
```

```
attempt to perform arithmetic on a table value (field '?')
```

`(. sections (+ i 1))` returns the table at index `i+1`, e.g.
`{:pos 42 :title "..."}`. The `-` operator then received that table as its
first operand, which is not valid. The intent was to get `sections[i+1].pos`
and subtract `1` from it.

In Fennel, field access chains must be written explicitly — there is no
implicit field dereference in arithmetic position. The expression
`(- (. sections (+ i 1)) :pos 1)` does not mean "get `.pos` from the result
and subtract 1"; it means "subtract `:pos` and `1` from the table", which is
a type error.

**Decision:**

Bind the intermediate table to a local before extracting the field:

```fennel
(let [next-sec (. sections (+ i 1))]
  (- next-sec.pos 1))
```

A nested `.` call is also valid but less readable:

```fennel
(- (. (. sections (+ i 1)) :pos) 1)
```

The `let` binding form is preferred for clarity.

**Consequences:**

- The fix is local and does not affect surrounding logic.
- The `let` binding makes the intent explicit: get the next section, then
  access its position.
- This is a general Fennel pattern: any time a table access result is needed in
  an arithmetic or comparison expression, bind it first.

---

## ADR-004: Inject Arguments via `_G` Instead of Passing to `fennel.dofile`

**Status:** Accepted

**Context:**

The initial shim passed a filename as a second argument to `fennel.dofile`:

```lua
require('fennel').dofile('my-script.fnl', texFile)
```

This caused a runtime error:

```
fennel.utils.copy: table expected, got string
```

`fennel.dofile`'s signature is `fennel.dofile(filename, options)`, where
`options` is an optional table of compiler options. The second argument is not
a mechanism for passing user data into the script — it is silently coerced into
an options table, causing the copy utility to fail when it receives a string
instead.

There is no supported mechanism in `fennel.dofile` to forward arbitrary
arguments to the script being loaded.

**Decision:**

Inject values into `_G` (the global table) before calling `fennel.dofile`, and
read them from `_G` inside the Fennel script:

```lua
-- run_script.lua
_G.input_filename = arg[1]
require('fennel').dofile('my-script.fnl')  -- no second argument
```

```fennel
;; my-script.fnl
(local input-filename (or _G.input_filename (error "No input file provided")))
```

The `arg[1]` value is passed on the command line from the makefile:

```makefile
split-tex:
	@texlua --luaonly run_split.lua $(FILE)
```

**Consequences:**

- Values passed via `_G` are global for the duration of the process. This is
  acceptable here since the script is a short-lived single-purpose process.
- The Fennel script must guard against a missing value explicitly — there is no
  type enforcement at the boundary.
- `fennel.dofile` must always be called with no second argument, or with a
  valid options table. Passing any other type will reproduce the original error.
- An alternative would be passing arguments via environment variables
  (`os.getenv`), but this adds indirection and requires the makefile to set
  env vars rather than passing CLI arguments directly.