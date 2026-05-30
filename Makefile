.PHONY: help init fmt fmt-check lint validate security docs clean pre-commit pre-commit-install pre-commit-all check fix all

SHELL := /bin/bash
MODULES_DIR := aws-tf/modules
LIVE_DIR := aws-tf/live

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# ─── Setup ──────────────────────────────────────────────────────────────────

init: ## Install pre-commit hooks and tflint plugins
	@echo "$(GREEN)>>> Installing pre-commit hooks...$(NC)"
	pre-commit install
	@echo "$(GREEN)>>> Installing tflint plugins...$(NC)"
	tflint --init --config .tflint.hcl
	@echo "$(GREEN)>>> Setup complete!$(NC)"

pre-commit-install: ## Install pre-commit hooks only
	pre-commit install

# ─── Formatting ─────────────────────────────────────────────────────────────

fmt: ## Format all Terraform and Terragrunt files
	@echo "$(GREEN)>>> Formatting Terraform files...$(NC)"
	tofu fmt -recursive $(MODULES_DIR)
	@echo "$(GREEN)>>> Formatting Terragrunt HCL files...$(NC)"
	@find $(LIVE_DIR) -name '*.hcl' -not -path '*/.terragrunt-cache/*' -not -name '.terraform.lock.hcl' \
		| while read -r f; do \
			tofu fmt "$$f" 2>/dev/null || true; \
		done
	@echo "$(GREEN)>>> Done!$(NC)"

fmt-check: ## Check formatting without modifying files
	@echo "$(GREEN)>>> Checking Terraform format...$(NC)"
	@tofu fmt -recursive -check -diff $(MODULES_DIR)
	@echo "$(GREEN)>>> All files formatted correctly!$(NC)"

# ─── Linting ────────────────────────────────────────────────────────────────

lint: ## Run tflint on all modules
	@echo "$(GREEN)>>> Linting Terraform modules...$(NC)"
	@for dir in $(MODULES_DIR)/*/; do \
		echo "$(YELLOW)  → $${dir}$(NC)"; \
		tflint --chdir="$${dir}" --config="$(CURDIR)/.tflint.hcl" || exit 1; \
	done
	@echo "$(GREEN)>>> Linting complete!$(NC)"

# ─── Validation ─────────────────────────────────────────────────────────────

validate: ## Validate all Terraform modules
	@echo "$(GREEN)>>> Validating Terraform modules...$(NC)"
	@for dir in $(MODULES_DIR)/*/; do \
		echo "$(YELLOW)  → $${dir}$(NC)"; \
		(cd "$${dir}" && tofu init -backend=false -input=false > /dev/null 2>&1 && tofu validate) || exit 1; \
	done
	@echo "$(GREEN)>>> Validation complete!$(NC)"

# ─── Security ───────────────────────────────────────────────────────────────

security: ## Run Trivy security scan on all modules
	@echo "$(GREEN)>>> Running security scan...$(NC)"
	trivy config $(MODULES_DIR) \
		--severity HIGH,CRITICAL \
		--skip-dirs '**/.terragrunt-cache'
	@echo "$(GREEN)>>> Security scan complete!$(NC)"

# ─── Documentation ──────────────────────────────────────────────────────────

docs: ## Generate terraform-docs for all modules (requires terraform-docs)
	@echo "$(GREEN)>>> Generating module documentation...$(NC)"
	@for dir in $(MODULES_DIR)/*/; do \
		echo "$(YELLOW)  → $${dir}$(NC)"; \
		terraform-docs markdown table --output-file README.md "$${dir}" 2>/dev/null || \
			echo "$(RED)  ⚠ terraform-docs not installed, skipping$(NC)"; \
	done
	@echo "$(GREEN)>>> Documentation complete!$(NC)"

# ─── Pre-commit ─────────────────────────────────────────────────────────────

pre-commit: ## Run pre-commit on staged files
	pre-commit run

pre-commit-all: ## Run pre-commit on all files
	pre-commit run --all-files

# ─── Combined ───────────────────────────────────────────────────────────────

check: fmt-check lint validate security ## Run all checks (CI mode — no modifications)

fix: fmt lint ## Format and lint all files

all: fmt lint validate security ## Run everything (format + lint + validate + security)

# ─── Cleanup ────────────────────────────────────────────────────────────────

clean: ## Remove .terragrunt-cache and .terraform directories
	@echo "$(YELLOW)>>> Cleaning up cache directories...$(NC)"
	find . -type d -name '.terragrunt-cache' -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name '.terraform' -exec rm -rf {} + 2>/dev/null || true
	find . -name '*.tfplan' -delete 2>/dev/null || true
	@echo "$(GREEN)>>> Cleanup complete!$(NC)"
