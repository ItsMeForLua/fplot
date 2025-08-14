package = "fplot"
version = "1.0.2-2"

source = {
  url = "git+https://github.com/ItsMeForLua/fplot.git",
  tag = "v1.0.2-2"
}

description = {
  summary = "A declarative plotting library for Fennel and Lua, powered by Gnuplot.",
  detailed = [[
    fplot provides a clean, table-based API to gnuplot, allowing you to
    define and generate plots directly from your Fennel or Lua code.
  ]],
  homepage = "https://github.com/ItsMeForLua/fplot",
  license = "LGPL-3.0"
}

dependencies = {
  "lua >= 5.1",
  "fennel >= 1.0.0" 
}

build = {
  type = "command",
  install_command = [[
    cp fplot.fnl "$(LUA_DIR)"
  ]]
}
