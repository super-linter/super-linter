# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: test ## Run all targets.

.PHONY: test
test: kcov ## Run tests

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: kcov
kcov: ## Run kcov
	docker run --rm -t $(DOCKER_FLAGS) \
		-v "$(CURDIR)":/workspace \
		-w="/workspace" \
		kcov/kcov \
		kcov \
		--bash-parse-files-in-dir=/workspace \
		--clean \
		--exclude-pattern=.coverage,.git \
		--include-pattern=.sh  \
		/workspace/test/.coverage \
		/workspace/test/runTests.sh

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
