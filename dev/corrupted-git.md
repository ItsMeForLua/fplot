# Source - https://stackoverflow.com/a/46604551
# Posted by Zoey Hewll, modified by community. See post 'Timeline' for change history
# Retrieved 2026-06-05, License - CC BY-SA 4.0

``` bash
mv -v .git .git_old &&            # Remove old Git files
git init &&                       # Initialise new repository
git remote add origin "https://github.com/ItsMeForLua/fplot.git" && # Link to old repository
git fetch &&                      # Get old history
# Note that some repositories use 'master' in place of 'main'. Change the following line if your remote uses 'master'.
git reset origin/main --mixed     # Force update to old history.
```