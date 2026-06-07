.PHONY: help clean-tex clean-scripts clean-lwarp clean-html clean-all-exclude-html clean-all-include-html n-tree lwarpmk limages find-html-deps compile-tex html auto-run
.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo "  make clean-tex                 Remove TeX build artifacts"
	@echo "  make clean-scripts             Remove script output artifacts"
	@echo "  make clean-lwarp               Remove lwarp artifacts"
	@echo "  make clean-html                Remove html/ directory"
	@echo "  make clean-all-exclude-html    Clean all artifacts except html/"
	@echo "  make clean-all-include-html    Clean all artifacts including html/"
	@echo "  make html FILE=<name>          Build html/ from <name>.html"
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

clean-html:
	@echo "Cleaning html/ completely..."
	@rm -rf html/

clean-all-exclude-html:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@echo "Cleaned project of all artifacts excluding html/..."

clean-all-include-html:
	@$(MAKE) clean-tex
	@$(MAKE) clean-scripts
	@$(MAKE) clean-lwarp
	@$(MAKE) clean-html
	@echo "Cleaned project of all artifacts including html/..."

html:
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
	@echo "Building html/ directory..."
	@mkdir -p html
	@cp "tex/$(FILE).html" html/index.html
	@cp tex/*.html html/ 2>/dev/null || true
	@cp tex/lwarp.css tex/lwarp_formal.css tex/lwarp_sagebrush.css tex/lwarp_mathjax.txt html/ 2>/dev/null || true
	@grep -oE '(href|src)="[^"]+"' tex/*.html | \
		sed -n 's/.*="\([^/:][^"]*\)".*/\1/p' | \
		sort -u | \
		while read -r file; do \
			if [ -e "tex/$$file" ]; then \
				mkdir -p "html/$$(dirname "$$file")"; \
				cp -r "tex/$$file" "html/$$file"; \
				echo "Copied asset: tex/$$file to html/$$file"; \
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
	@echo "Injecting Highlight.js into all HTML <head> tags..."
	@for html_file in tex/*.html; \
	do \
		awk '/<\/head>/ { \
			print "<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/stackoverflow-light.min.css\">"; \
			print "<style>.hljs { background: transparent !important; padding: 0 !important; }</style>"; \
			print "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js\"></script>"; \
			print "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/lisp.min.js\"></script>"; \
			print "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/lua.min.js\"></script>"; \
			print "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/bash.min.js\"></script>"; \
			print "<script>"; \
			print "document.addEventListener(\"DOMContentLoaded\", () => {"; \
			print "  document.querySelectorAll(\"pre.programlisting\").forEach(el => {"; \
			print "    const rawText = el.textContent;"; \
			print "    const code = document.createElement(\"code\");"; \
			print "    // Auto-detect Bash, Lua, or default to Lisp for Fennel"; \
			print "    if (rawText.includes(\"git clone\") || rawText.includes(\"cd \") || rawText.includes(\"make \") || rawText.trim().startsWith(\"$$\")) {"; \
			print "      code.className = \"language-bash\";"; \
			print "    } else if (rawText.includes(\"function\") || rawText.includes(\"local \") || rawText.includes(\"require(\")) {"; \
			print "      code.className = \"language-lua\";"; \
			print "    } else {"; \
			print "      code.className = \"language-lisp\";"; \
			print "    }"; \
			print "    code.textContent = rawText;"; \
			print "    el.innerHTML = \"\";"; \
			print "    el.appendChild(code);"; \
			print "    hljs.highlightElement(code);"; \
			print "  });"; \
			print "});"; \
			print "</script>"; \
		} 1' "$$html_file" > "$$html_file.tmp" && mv "$$html_file.tmp" "$$html_file"; \
	done

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
	@echo "Compiling $(FILE).tex into $(FILE).pdf..."
	@cd tex && lualatex "$(FILE).tex"
	@cd tex && biber "$(FILE)"
	@cd tex && lualatex "$(FILE).tex"
	@cd tex && lualatex "$(FILE).tex"

auto-run:
	@test -n "$(FILE)" || (echo "Usage: make auto-run FILE=YourFile" >&2; exit 1)
	@$(MAKE) clean-all-include-html FILE="$(FILE)"
	@$(MAKE) compile-tex FILE="$(FILE)"
	@$(MAKE) lwarpmk FILE="$(FILE)"
	@$(MAKE) limages FILE="$(FILE)"
	@$(MAKE) html FILE="$(FILE)"
	@$(MAKE) clean-all-exclude-html FILE="$(FILE)"
	@rm -rf tex/html 2>/dev/null || true
	@rm -rf tex/imgs 2>/dev/null || true
	@rm $(FILE).pdf 2>/dev/null || true
	@echo "FILE=$(FILE): completed."
