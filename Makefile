# COLORS
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
LBLUE := \033[36m
RESET := \033[0m
NC := $(RESET)

ALL_TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1)
.SILENT:
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

TARGET ?= env.d/.env.gentoo-amd64

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

########
# HELP #
########

help: ## Display this help
	echo ""
	echo "$(YELLOW)Available commands:$(RESET)"
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(LBLUE)%-20s$(RESET) %s\n", $$1, $$2}'
	echo ""

list-targets: ## List available targets.env.gentoo-amd64-m710q-alexception
	ls env.d -A1

init-target: ## Usage: make init TARGET=env.d/.env.gentoo-amd64-m710q-alexception
	echo "Environment configuration for $(LBLUE)$(TARGET)$(NC)..."
	if ! [ -f "$(TARGET)" ] ; then \
		echo "$(RED)[KO]$(NC) file $(LBLUE)$(TARGET)$(NC) does not exist." ; \
		exit 1 ; \
	fi
	if [ -f ".env" ] ; then \
		grep -vE '^\s*$$|^\s*#' .env | sort > .tmp_env_current ; \
		grep -vE '^\s*$$|^\s*#' $(TARGET) | sort > .tmp_env_new ; \
		if ! cmp -s .tmp_env_current .tmp_env_new ; then \
			OVERRIDE="n" ; \
			echo "$(YELLOW)[!!] File .env differs. Here are the changed variables:$(NC)" ; \
			diff -u .tmp_env_current .tmp_env_new || true ; \
			echo "$(YELLOW)Are you sure to replace it (y/n)? [n]$(NC)" ; \
			read OVERRIDE ; \
			if [ "$$OVERRIDE" = "y" ] ; then \
				cp $(TARGET) .env ; \
				echo "$(GREEN)[OK]$(NC) Replaced $(LBLUE).env$(NC) by $(LBLUE)$(TARGET)$(NC)." ; \
			else \
				echo "$(RED)[KO]$(NC) Operation aborted by user." ; \
			fi ; \
		else \
			echo "$(GREEN)[OK]$(NC) $(LBLUE).env$(NC) content is already up to date wit default target $(LBLUE)$(TARGET)$(NC)." ; \
		fi ; \
		rm -f .tmp_env_current .tmp_env_new ; \
	else \
		cp $(TARGET) .env ; \
		echo "$(GREEN)[OK]$(NC) Updated $(LBLUE).env$(NC) from $(LBLUE)$(TARGET)$(NC)." ; \
	fi

bootable-key: init-target ## Create bootable key
	./bootable_key.sh
