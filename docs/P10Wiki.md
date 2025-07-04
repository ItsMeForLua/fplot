# Troubleshooting Guide

This guide provides solutions to common problems you might encounter when using `fplot` in different environments.

## General Issues

#### Problem: `gnuplot` not found or command fails.

When you run an `fplot` script, and you see an error like `sh: gnuplot: command not found` or a non-zero exit code.

**Solution:**

1. **Verify `gnuplot` Installation:** Make sure `gnuplot` is installed on your system. See the [Installation](https://www.google.com/search?q=https://github.com/your-username/fplot/wiki/Installation "null") guide.

2. **Check System `PATH`:** The `gnuplot` executable must be in your system's `PATH`. You can check this by opening a terminal and typing `gnuplot --version`. If it's not found, you need to add its location to your `PATH` environment variable.

3. **Hardcode the Path:** As a last resort, you can edit your local `fplot.fnl` (or `fplot.lua`) file and change the `gnuplot-executable` variable to the full, absolute path of the `gnuplot` executable on your system.

#### Problem: The plot window appears and immediately closes.

Solution:

This typically happens when gnuplot is not run in "persistent" mode. fplot automatically handles this by adding the -p flag or a pause mouse close command when it's not saving to a file. If you are running gnuplot scripts manually, make sure to use the -p flag: gnuplot -p your_script.gp.

## MSYS2 (on Windows)

The MSYS2 environment can be tricky because of how it handles file paths.

#### Problem: `fplot` fails with errors like "Can't open script file" or "Cannot find data file".

This is the most common issue on MSYS2 and is caused by **path mangling**. MSYS2 automatically converts POSIX-style paths (e.g., `/c/Users/Me`) to Windows-style paths (`C:\Users\Me`) when calling native Windows programs like `gnuplot`. This can corrupt the paths to the temporary script and data files that `fplot` creates.

**Solution 1: Disable Path Mangling (Recommended)**

You can tell MSYS2 not to convert paths by setting an environment variable before running your script.

```bash
# In your MSYS2 terminal
export MSYS2_ARG_CONV_EXCL="*"
fennel your_plot_script.fnl
```

To make this permanent, add `export MSYS2_ARG_CONV_EXCL="*"` to your `.bashrc` or `.bash_profile` file in your MSYS2 home directory.

**Solution 2: Use the MinGW `gnuplot` Package**

Within your MSYS2 environment, it's best to use the `gnuplot` package from the MinGW repositories, as it's a native Windows build that integrates well with the environment. You can install it using `pacman`:

```bash
pacman -S mingw-w64-x86_64-gnuplot
```

This version is generally more reliable for GUI applications than a purely POSIX-emulated build. However, even with this version, the path mangling described in Solution 1 is often still a problem, so disabling it is the most robust fix.

## WSL2 (Windows Subsystem for Linux)

WSL2 runs a full Linux kernel. On modern Windows 10 and 11, the **WSLg** feature provides built-in support for Linux GUI applications, so they should work out of the box.

**Problem:** The script runs, but no plot window appears. You might see an error like "cannot open display" or "Gnuplot terminal type set to 'unknown'".

**Solution for Modern Windows (with WSLg):**

1. **Ensure WSL is Up-to-Date:** Open a Windows PowerShell or Command Prompt and run `wsl --update`. This will ensure you have the latest version with WSLg.

2. **Install a GUI-enabled `gnuplot`:** Your Linux distribution needs a version of `gnuplot` that can create a graphical window.
   
   ```bash
   # On Debian/Ubuntu
   sudo apt-get update
   sudo apt-get install gnuplot-x11
   ```
   
   This should be all you need. When you run your `fplot` script from WSL2, the plot window should appear on your Windows desktop automatically(appearance is slow).

**Solution for Older Windows Versions (without WSLg):**

If you are on an older build of Windows that doesn't support WSLg, you will need to manually install an X server on Windows.

1. **Install an X Server on Windows:** Download and install a free X server like [**VcXsrv**](https://sourceforge.net/projects/vcxsrv/ "null") on your Windows machine.

2. **Launch the X Server:** Launch VcXsrv and choose "Multiple windows", "Display number -1", and on the final page, check "Disable access control".

3. **Configure the `DISPLAY` Variable in WSL2:** Your Linux environment needs to know where the display is. Add the following line to your `.bashrc` file in your WSL2 home directory (`~/.bashrc`):
   
   ```bash
   export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
   ```

4. **Reload Your Shell:** Close and reopen your WSL2 terminal, or run `source ~/.bashrc`. After this, GUI applications from WSL2 should appear on your desktop.

## Native Linux / macOS

`fplot` is most at home on these systems and issues are rare.

#### Problem: `fplot` complains about a missing terminal type (e.g., "Terminal type set to 'unknown'").

Solution:

Your gnuplot installation may be missing support for interactive terminals. When you installed gnuplot, you may have gotten a "core" or "nogui" version. Re-install it and ensure you get a version with qt or x11 support.

- **Debian/Ubuntu:** `sudo apt-get install gnuplot-x11` or `sudo apt-get install gnuplot-qt`

- **Arch Linux:** The default `gnuplot` package should be sufficient.

- **macOS (Homebrew):** `brew install gnuplot` should install a version with the `qt` terminal.

You can check which terminals your `gnuplot` supports by running `gnuplot -e "show terminal"`.

## A Note on Gnuplot Terminals (GUI Backends)

#### Problem: A plot window appears, but it's buggy, slow, or doesn't appear at all, even though `gnuplot` is installed correctly.

Solution:

gnuplot uses different internal engines, called "terminals," to draw its interactive plot windows. The most common ones are wxt (the default on many systems), qt, and x11. Sometimes, the default terminal may have issues with your specific desktop environment or system configuration, especially in complex setups like MSYS2.

If you suspect this is the issue, you can force `fplot` to use a different terminal by setting the `:output-type` option in your plot configuration.

**Example (forcing the `qt` terminal):**

```fennel
(fplot.plot
  {:options {:title "My Plot"
             :output-type "qt"} ; <-- Force the qt terminal
   :datasets [;...
             ]})
```

This is a powerful troubleshooting step. If the default `wxt` terminal fails, try `qt`. If `qt` fails, try `x11` (on Linux). Make sure you have the necessary support libraries installed for the terminal you want to use (e.g., the `gnuplot-qt` package on Debian/Ubuntu for the `qt` terminal).
