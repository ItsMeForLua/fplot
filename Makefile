.PHONY: all split compile-pdf build-wiki clean clean-chunks clean-wiki auto-run

.DEFAULT_GOAL := help

clean-scripts:
	@echo "Cleaning directory of scripts (and IDE) artifacts..."
	@rm -f *.txt *.json
	@rm -f tex/*.txt tex/*.json tex/~*
	@find . -not -path './.git/*' \( -name '#*#' -o -name '*~' -o -name '~*' \) | xargs rm -f

# n.b., Here we're using [], because if we did brace expansion {}, it would only work with bash.
# But, make files use POSIX standard (/bin/sh)---NOT bash.
clean-tex:
	@echo "Cleaning directory of tex artifacts..."
	@rm -f tex/[0-9]*.tex tex/[0-9]*.log \
	       tex/[0-9]*.aux tex/[0-9]*.out tex/[0-9]*.toc \
	       tex/*wiki.aux tex/*wiki.log tex/*wiki.out tex/*wiki.toc \
	       tex/*.gz

split-tex:
	@echo "Splitting $(FILE)..."
	@mkdir -p tex
	@texlua --luaonly run_split.lua $(FILE)
# n.b., FILE is passed as arg[1] to the shim, not as an env var.
# fennel.dofile has no mechanism to forward arguments, so the shim...
# injects it into _G. The relevant files are run_split.lua and split_tex.fnl.

compile-pdf:
	@echo "Compiling fplot_wiki.tex..."
	@cd tex && lualatex -interaction=batchmode fplot_wiki.tex > /dev/null
	@echo "Done: tex/fplot_wiki.pdf"

build-wiki: $(patsubst tex/%.tex,wiki/%.md,$(wildcard tex/[0-9]*.tex))
	@echo "The Markdown wiki pages should be in wiki/."

wiki/%.md: tex/%.tex
	@echo " -> Converting $< to $@"
	@mkdir -p wiki
	@pandoc $< -f latex -t gfm --lua-filter=filters/lua-filter.lua -o $@

clean-wiki:
	@echo "Cleaning wiki/ markdown files..."
	@rm -f wiki/*.md

clean-all-exclude-wiki:
	@echo "Cleaning all artifacts (excluding wiki)..."
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@rm -f tex/fplot_wiki.pdf tex/fplot_wiki.synctex.gz
	@echo "Workspace cleaned (excluding wiki)."

clean-all-include-wiki: 
	@echo "Cleaning all artifacts (including wiki)..."
	@$(MAKE) clean-tex
	@$(MAKE) clean-wiki
	@$(MAKE) clean-scripts
	@rm -f tex/fplot_wiki.pdf tex/fplot_wiki.synctex.gz
	@echo "Workspace cleaned (including wiki)."

auto-run:
	@$(MAKE) clean-all-include-wiki
	@$(MAKE) split-tex
	@$(MAKE) compile-pdf
	@$(MAKE) build-wiki
	@$(MAKE) clean-tex