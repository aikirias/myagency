.PHONY: help install install-likec4 install-openspec install-understand-anything check-node validate-claude

SHELL := /bin/bash

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-38s %s\n", $$1, $$2}'

# ─── Prerequisites ────────────────────────────────────────────────────────────

check-node: ## Verify Node.js >= 20 is available
	@command -v node >/dev/null 2>&1 || \
		(echo "ERROR: Node.js not found. Install via nvm: https://github.com/nvm-sh/nvm" && exit 1)
	@node -e "const v = parseInt(process.versions.node); \
		if (v < 20) { \
			console.error('ERROR: Node.js >= 20 required, found: ' + process.version); \
			console.error('Run: nvm install 20 && nvm use 20'); \
			process.exit(1); \
		}"
	@echo "Node.js $$(node --version) OK"

# ─── Install all ──────────────────────────────────────────────────────────────

install: check-node install-likec4 install-openspec install-understand-anything ## Install all three tools
	@echo ""
	@echo "Installation complete."
	@echo "  likec4   $$(likec4 --version 2>/dev/null || echo 'not in PATH — check nvm is active')"
	@echo "  openspec $$(openspec --version 2>/dev/null || echo 'not in PATH — check nvm is active')"

# ─── LikeC4 ───────────────────────────────────────────────────────────────────

install-likec4: check-node ## Install LikeC4 CLI (architecture-as-code diagrams)
	npm install -g likec4
	@echo ""
	@echo "LikeC4 installed."
	@echo "  Verify : likec4 --version"
	@echo "  Preview: likec4 serve architecture/<file>.likec4"
	@echo "  Build  : likec4 build architecture/<file>.likec4 --output docs/architecture/"
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

install-understand-anything: ## Install Understand Anything as a Claude Code native plugin
	@echo "Understand Anything must be installed inside Claude Code."
	@echo ""
	@echo "Run these slash commands in Claude Code:"
	@echo "  /plugin marketplace add Lum1104/Understand-Anything"
	@echo "  /plugin install understand-anything"
	@echo ""
	@echo "Then run /understand to build the knowledge graph for this repo."
	@echo "Docs: https://github.com/Lum1104/Understand-Anything"

# ─── Claude surface validation ────────────────────────────────────────────────

validate-claude: ## Validate agent, skill, command, and rule structure
	python3 scripts/validate_claude_structure.py
