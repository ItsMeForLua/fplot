package = "fplot"
version = "1.0.3-3"
source = {
  url = "git+https://github.com/ItsMeForLua/fplot.git",
  tag = "v1.0.3-3"
}
description = {
  summary = "A declarative plotting library for Fennel and Lua, powered by Gnuplot.",
  homepage = "https://github.com/ItsMeForLua/fplot",
  license = "LGPL-3.0"
}
dependencies = {
  "lua >= 5.1",
  "fennel >= 1.0.0",
  "luarocks-build-fennel >= 0.1"
}
build = {
  type = "builtin",
  build_helper = "luarocks-build-fennel",
  modules = {
    fplot = "fplot.fnl"
  }
}
