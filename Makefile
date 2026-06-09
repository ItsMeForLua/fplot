.PHONY: help clean-tex clean-scripts clean-lwarp clean-docs clean-all-exclude-docs clean-all-include-docs n-tree lwarpmk limages find-html-deps compile-tex docs auto-run
.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo "  make clean-tex                 Remove TeX build artifacts"
	@echo "  make clean-scripts             Remove script output artifacts"
	@echo "  make clean-lwarp               Remove lwarp artifacts"
	@echo "  make clean-docs                Remove docs/ directory"
	@echo "  make clean-all-exclude-docs    Clean all artifacts except docs/"
	@echo "  make clean-all-include-docs    Clean all artifacts including docs/"
	@echo "  make docs FILE=<name>          Build docs/ from <name>.html"
	@echo "  make lwarpmk FILE=<name>       Run lwarpmk html <name>"
	@echo "  make limages FILE=<name>       Run lwarpmk limages if <name>-images.txt exists"
	@echo "  make find-html-deps FILE=<name> List href/src dependencies from <name>.html"
	@echo "  make compile-tex FILE=<name>   Compile <name>.tex to PDF"
	@echo "  make auto-run FILE=<name>      Run full build pipeline"

clean-tex: 
	@echo "Cleaning directory of tex artifacts..."
	@rm -f *.aux *.bbl *.bcf *.blg *.log *.run.xml *.synctex.gz *.out *.toc
	@rm -f tex/*.aux tex/*.bbl tex/*.bcf tex/*.blg tex/*.log tex/*.run.xml tex/*.synctex.gz tex/*.out tex/*.toc

clean-scripts:
	@echo "Cleaning directory of scripts artifacts..."
	@rm -f *.txt *.json ~*
	@rm -f tex/*.txt tex/*.json tex/~*

clean-lwarp:
	@echo "Cleaning directory of lwarp artifacts..."
	@rm -f *.lwarpmkconf *_html.tex *.cut *.css *.ist *.conf *.xdy *_html.pdf *.sidetoc *.html
	@rm -f tex/*.lwarpmkconf tex/*_html.tex tex/*.cut tex/*.listing tex/.log tex/*.css tex/*.ist tex/*.conf tex/*.xdy tex/*_html.pdf tex/*.sidetoc tex/*.html

clean-docs:
	@echo "Cleaning docs/ completely..."
	@rm -rf docs/

clean-all-exclude-docs:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@echo "Cleaned project of all artifacts excluding docs/..."

clean-all-include-docs:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@$(MAKE) clean-docs
	@echo "Cleaned project of all artifacts including docs/..."

docs:
	@echo "FILE is currently set to: '$(FILE)'"; \
	if [ -z "$(FILE)" ]; then \
		echo "Warning: FILE is empty."; \
		echo "Expected usage: make docs FILE=File-Name-Without-Extension"; \
		exit 1; \
	fi; \
	printf "Proceed? [y/N] "; \
	read ans; \
	case "$$ans" in \
		[yY]|[yY][eE][sS]) ;; \
		*) echo "Aborted."; exit 1 ;; \
	esac
	@echo "Building docs/ directory..."
	@mkdir -p docs
	@cp "tex/$(FILE).html" docs/index.html
	@cp tex/*.html docs/ 2>/dev/null || true
	@cp tex/lwarp.css tex/lwarp_formal.css tex/lwarp_sagebrush.css tex/lwarp_mathjax.txt docs/ 2>/dev/null || true
	@grep -oE '(href|src)="[^"]+"' tex/*.html | \
		sed -n 's/.*="\([^/:][^"]*\)".*/\1/p' | \
		sort -u | \
		while read -r file; do \
			if [ -e "tex/$$file" ]; then \
				mkdir -p "docs/$$(dirname "$$file")"; \
				cp -r "tex/$$file" "docs/$$file"; \
				echo "Copied asset: tex/$$file to docs/$$file"; \
			fi; \
		done

lwarpmk:
	@rm -f "tex/$(FILE).html"  # prevent lwarpmk timestamp skip on first call
	@echo "Generating HTML bibliography via Biber..."
	@cd tex && lwarpmk html "$(FILE)"
	@cd tex && biber "$(FILE)_html"
	@echo "Running two lualatex passes to resolve citations..."
	@cd tex && lualatex "$(FILE)_html.tex"
	@cd tex && lualatex "$(FILE)_html.tex"
	@echo "Running lwarpmk html $(FILE) final pass..."
	@rm -f "tex/$(FILE).html"
	@cd tex && lwarpmk html "$(FILE)"
	@echo "Injecting custom structural CSS into lwarp.css..."
	@echo "/* --- CUSTOM CODE BLOCK STRUCTURE --- */" >> tex/lwarp.css
	@echo "pre.programlisting { background-color: #f0f0f0; border: 1.5pt solid black; padding: 10px; margin-bottom: 1.5em; overflow-x: auto; white-space: pre-wrap; font-family: monospace; }" >> tex/lwarp.css
	@echo "Cleaning up lwarp codeblocks and injecting static highlighting with texlua..."
	@texlua --luaonly run_build_docs.lua tex

limages:
	@echo "Running lwarpmk limages for $(FILE)..."
	@if [ -f "tex/$(FILE)-images.txt" ]; then \
		cd tex && lwarpmk limages "$(FILE)"; \
	else \
		echo "No $(FILE)-images.txt found; skipping limages."; \
	fi

find-html-deps:
	@grep -oE '(href|src)="[^"]+"' 'tex/$(FILE).html'

compile-tex:
	@echo "Compiling $(FILE).tex into $(FILE).pdf (Pass 1: Draft)..."
	@cd tex && lualatex -draftmode -interaction=nonstopmode -halt-on-error "$(FILE).tex" > /dev/null
	@echo "Running Biber..."
	@cd tex && biber "$(FILE)" > /dev/null
	@echo "Compiling $(FILE).tex into $(FILE).pdf (Pass 2: Draft for TOC/Refs)..."
	@cd tex && lualatex -draftmode -interaction=nonstopmode -halt-on-error "$(FILE).tex" > /dev/null
	@echo "Compiling $(FILE).tex into $(FILE).pdf (Pass 3: Final PDF)..."
	@cd tex && lualatex "$(FILE).tex"

build-sourcehut-tar:
	@cd docs && tar -czf ../site.tar.gz .

auto-run:
	@test -n "$(FILE)" || (echo "Usage: make auto-run FILE=YourFile" >&2; exit 1)
	@$(MAKE) clean-all-include-docs FILE="$(FILE)"
	@$(MAKE) compile-tex FILE="$(FILE)"
	@$(MAKE) lwarpmk FILE="$(FILE)"
	@$(MAKE) limages FILE="$(FILE)"
	@$(MAKE) docs FILE="$(FILE)"
	@$(MAKE) clean-all-exclude-docs FILE="$(FILE)"
	@rm -rf tex/docs 2>/dev/null || true
	@rm -f tex/imgs/lateximg-* 2>/dev/null || true
	@rm $(FILE).pdf 2>/dev/null || true
	@echo "FILE=$(FILE): completed."

