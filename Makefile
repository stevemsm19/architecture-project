.PHONY: pdf

pdf:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: FILE argument is required. Usage: make pdf FILE=documentation/reports/lab2.md"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "Error: File '$(FILE)' does not exist."; \
		exit 1; \
	fi
	@echo "Processing $(FILE)..."
	@mkdir -p documentation/build
	@# Extract base filename without extension
	$(eval BASENAME=$(shell basename $(FILE) .md))
	@# Generate Typst intermediate file
	@./documentation/scripts/generate.py $(FILE) documentation/build/$(BASENAME).typ
	@typst compile --root . documentation/build/$(BASENAME).typ documentation/build/$(BASENAME).pdf
	@echo "Success! Output generated at documentation/build/$(BASENAME).pdf"
