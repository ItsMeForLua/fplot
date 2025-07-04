-- fplot-1.0.1-1.rockspec
package = "fplot"
version = "1.0.1-1"

source = {
  url = "git+https://github.com/ItsMeForLua/fplot.git",
  tag = "v1.0.1"
}

description = {
  summary = "A declarative plotting library for Fennel and Lua, powered by Gnuplot.",
  detailed = [[
    fplot provides a clean, table-based API to gnuplot, allowing you to
    define and generate plots directly from your Fennel or Lua code.
    This package installs the Fennel source files directly.
  ]],
  homepage = "https://github.com/ItsMeForLua/fplot",
  license = "LGPL-3.0"
}

dependencies = {
  "lua >= 5.1"
}

build = {
  type = "command",
  build_command = "echo 'No build step required for a pure Fennel/Lua rock.'",
  install_command = [[
    cp fplot.fnl "$(LUADIR)"
    cp fennel.lua "$(LUADIR)"
  ]]
}