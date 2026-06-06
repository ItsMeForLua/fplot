-- This is simply my shim for split_tex.fnl
-- texlua does not support eval flags, so I can't do all this via the...
-- make recipe that invokes texlua.
package.path = './?.lua;./filters/?.lua'

-- I'm registering fennel under an alias before require touches the path to...
-- ...avoid dealing with the dots in the actual fennel file.
package.preload['fennel'] = loadfile('./filters/fennel-1.6.1.lua')

--n.b., arg[1] is passed from the makefile target as: texlua --luaonly run_split.lua
local texFile = arg and arg[1]
if not texFile or texFile == "" then
    error("Usage: texlua --luaonly run_split.lua <file.tex>")
end
-- n.b., dofile only takes a filename, so we must inject the value as a global...
-- that the Fennel script can read on the other side.
_G.input_filename = texFile
require('fennel').dofile('split_tex.fnl')