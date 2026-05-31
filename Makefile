.PHONY: help install install-likec4 install-openspec install-understand-anything check-node

SHELL := /bin/bash

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-38s %s\n", $$1, $$2}'

# ─── Prerequisites ────────────────────────────────────────────────────────────

check-node: ## Verify Node.js >= 18 is available
	@command -v node >/dev/null 2>&1 || \
		(echo "ERROR: Node.js is required. https://nodejs.org" && exit 1)
	@node -e "const v = parseInt(process.versions.node); \
		if (v < 18) { \
			console.error('ERROR: Node.js >= 18 required, found: ' + process.version); \
			process.exit(1); \
		}"
	@echo "Node.js $$(node --version) OK"

# ─── Install all ──────────────────────────────────────────────────────────────

install: check-node install-likec4 install-openspec install-understand-anything ## Install all three tools
	@echo ""
	@echo "Installation complete."
	@echo "  likec4    $$(likec4 --version 2>/dev/null || echo 'not in PATH')"
	@echo "  openspec  $$(openspec --version 2>/dev/null || echo 'not in PATH')"
	@echo "  understand-anything: see instructions above"

# ─── LikeC4 ───────────────────────────────────────────────────────────────────

install-likec4: check-node ## Install LikeC4 CLI (architecture-as-code diagrams)
	npm install -g @likec4/cli
	@echo ""
	@echo "LikeC4 installed."
	@echo "  Verify : likec4 --version"
	@echo "  Preview: likec4 serve <file.likec4>"
	@echo "  Build  : likec4 build <file.likec4>"
	@echo "  Docs   : https://likec4.dev/docs"
	@echo ""
	@echo "Architecture files go in: architecture/"

# ─── OpenSpec ─────────────────────────────────────────────────────────────────

install-openspec: check-node ## Install OpenSpec CLI (spec-driven development)
	npm install -g @fission-ai/openspec@latest
	@echo ""
	@echo "OpenSpec installed."
	@echo "  Verify: openspec --version"
	@echo "  Docs  : https://openspec.dev"
	@echo ""
	@echo "Spec files go in: openspec/specs/<feature-name>/"

# ─── Understand Anything ──────────────────────────────────────────────────────

install-understand-anything: ## Install Understand Anything (Claude Code native plugin)
	@echo "Understand Anything is a Claude Code native plugin."
	@echo ""
	@echo "Option 1 — Claude Code slash commands (recommended):"
	@echo "  Open Claude Code, then run:"
	@echo "    /plugin marketplace add Lum1104/Understand-Anything"
	@echo "    /plugin install understand-anything"
	@echo ""
	@echo "Option 2 — Bash installer (Linux / macOS):"
	@read -p "Run the bash installer? [y/N] " confirm && [ "$$confirm" = "y" ] && \
		curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash || \
		echo "Skipped. Install manually: https://github.com/Lum1104/Understand-Anything"
	@echo ""
	@echo "After installing, run /understand in Claude Code to build the knowledge graph."
