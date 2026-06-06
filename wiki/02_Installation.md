# Installation

This page guides you through installing `fplot` and its required
dependencies.

## 1. Install gnuplot

`fplot` is a high-level interface for `gnuplot`, so you must have
`gnuplot` installed on your system.

### macOS

Using [Homebrew](https://brew.sh/):

``` bash
brew install gnuplot
```

### Debian / Ubuntu

``` bash
sudo apt-get update
sudo apt-get install gnuplot
```

### Arch Linux (&MSYS2)

``` bash
sudo pacman -S gnuplot
```

### Windows

You can download a `gnuplot` installer from the [official gnuplot
website](http://www.gnuplot.info/download.html). After installation,
ensure that the `gnuplot` executable is in your system’s `PATH`.

To verify the installation, open a terminal and run:

``` bash
gnuplot --version
```

You should see the installed version of `gnuplot`.

## 2. Install fplot

You can use [LuaRocks](https://luarocks.org/), *(the package manager for
Lua modules)*, to install `fplot`, or you can `git clone` the github
repository.

``` bash
luarocks install fplot
```

## 3. Verify the Installation

You can verify that `fplot` is installed correctly by running the
following code.

### Fennel

Create a file `test.fnl`:

``` lisp
(local fplot (require :fplot))
(print "fplot loaded successfully!")

(fplot.plot
{:options {:title "Test Plot"}
    :datasets [{:data [1 2 3 4]}]})
```

Run it from your terminal:

``` bash
fennel test.fnl
```

A plot window should appear with a simple line graph.

### Lua

Create a file `test.lua`:

``` lua
local fennel = require("fennel") fennel.install()
local fplot = require("fplot")
print("fplot loaded successfully!")

fplot.plot({
    options = { title = "Test Plot" },
    datasets = {
        { data = {1, 2, 3, 4} }
    }
})
```

Run it from your terminal:

``` bash
lua test.lua
```

A plot window should appear, just like the Fennel example.

If the plot window appears, you have successfully installed and
configured `fplot`!
