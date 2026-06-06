-- lua-filter.lua
-- Pandoc Lua filter for converting custom LaTeX environments and commands
-- to GitHub Flavored Markdown (gfm).
--
-- Usage:
--   pandoc input.tex -f latex -t gfm --lua-filter=filters/lua-filter.lua -o output.md
--
-- Handles:
--   Environments : warningbox, notebox, dangerbox, bugentry, lispcode, bashcode
--   Commands     : \code{}, \term{}, \pattern{}, \customitem{}{}, \multicomment{}
--   Listings     : \lstlisting with style=lua, style=python, style=bash, style=lisp, etc.
--
-- This file acts as a bridge. It loads the Fennel compiler and delegates
-- the actual AST traversal to our modular .fnl handlers.

local root = pandoc.path.directory(PANDOC_SCRIPT_FILE)

-- 1. Load the Fennel compiler (must be present in the filters/ directory)
local fennel = dofile(root .. "/fennel-1.6.1.lua")

-- 2. Add fennel's searcher to package.loaders just in case 
-- you ever want to use `require` inside your .fnl files.
table.insert(package.searchers or package.loaders, fennel.searcher)

-- 3. Execute our shared helpers file (this exposes globals to the other scripts)
fennel.dofile(root .. "/helpers.fnl")

-- 4. Load all modular handlers (each returns a table)
local modules = {
  fennel.dofile(root .. "/RawBlock.fnl"),
  fennel.dofile(root .. "/RawInline.fnl"),
  fennel.dofile(root .. "/Para.fnl"),
  fennel.dofile(root .. "/Div.fnl"),
  fennel.dofile(root .. "/CodeBlock.fnl"),
  fennel.dofile(root .. "/DefinitionList.fnl")
}

-- 5. Merge them into a single master filter table
local filter = {}
for _, mod in ipairs(modules) do
  for k, v in pairs(mod) do
    filter[k] = v
  end
end

-- 6. Return the filter to Pandoc!
return filter