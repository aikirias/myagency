.PHONY: help validate testbed-up testbed-down testbed-logs

SHELL := /bin/bash

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

validate: ## Validate marketplace + plugin structure (manifests, skills, hooks, deps)
	python3 scripts/validate_marketplace.py

testbed-up: ## Start the examples/local-stack testbed (Airflow + StarRocks + CloudBeaver)
	cd examples/local-stack && docker compose up -d --build

testbed-down: ## Stop the testbed
	cd examples/local-stack && docker compose down

testbed-logs: ## Tail testbed logs (SERVICE=<name> optional)
	cd examples/local-stack && docker compose logs -f $(SERVICE)
