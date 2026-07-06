# COLORS
YELLOW := \033[1;33m
BLUE := \033[36m
GREEN := \033[0;32m
RESET := \033[0m
ALL_TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1)
# Default make target
.DEFAULT_GOAL := help
# Make commmand silent without @ them
.SILENT:
# Must list all commands
.PHONY: $(ALL_TARGETS)

-include .env

current_user := $(shell id -un)

########
# HELP #
########

help:
	echo ""
	echo "$(YELLOW)Available commands:$(RESET)"
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-25s$(RESET) %s\n", $$1, $$2}'
	echo ""

################
# DEV COMMANDS #
################

dev-env-local-to-env: ## Copy .env.local to .env
	cp .env.local .env

dev-cleanup-env-local: ## Reinitialize .env with current logged in user
	echo 'AUTHOR_NAME="$(current_user)"' > .env
	echo 'AUTHOR_EMAIL=""' >> .env
	echo 'AUTHOR_GITHUB=""' >> .env

dev-cleanup-env: ## Cleanup .env file
	echo 'AUTHOR_NAME=""' > .env
	echo 'AUTHOR_EMAIL=""' >> .env
	echo 'AUTHOR_GITHUB=""' >> .env

dev-replace-author:  ## replace /author {#AUTHOR#} in files
	echo "author name: ${AUTHOR_NAME}"
	echo "author email: ${AUTHOR_EMAIL}"
	echo "author github: ${AUTHOR_GITHUB}"
