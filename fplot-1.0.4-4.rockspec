package = "fplot"
version = "1.0.4-4"
source = {
  url = "git+https://git.sr.ht/~itsmeforlua/fplot",
  tag = "v1.0.4-4"
}
description = {
  summary = "A declarative plotting library for Fennel and Lua that uses Gnuplot.",
  homepage = "https://git.sr.ht/~itsmeforlua/fplot",
  license = "LGPL-3.0"
}
dependencies = {
  "lua >= 5.1",
  "fennel >= 1.0.0",
  "luarocks-build-fennel >= 0.1"
}
build = {
  type = "fennel",
  modules = {
    fplot = "fplot.fnl"
  }
}
