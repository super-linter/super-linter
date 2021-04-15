# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: test ## Run all targets.

.PHONY: test
test: kcov prepare-test-reports ## Run tests

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

COBERTURA_REPORTS := $(shell find $(CURDIR) -name 'cobertura.xml')
COBERTURA_REPORTS_DIRECTORIES := $(dir $(COBERTURA_REPORTS))
COBERTURA_REPORTS_DESTINATION_DIRECTORY := "test/reports/cobertura"

.PHONY: prepare-test-reports
prepare-test-reports: ## Prepare the test reports for consumption
	mkdir -p $(COBERTURA_REPORTS_DESTINATION_DIRECTORY); \
	for path in "$(COBERTURA_REPORTS_DIRECTORIES)"; do \
		COBERTURA_REPORT_FILE_PATH="$$path"cobertura.xml; \
		echo $$COBERTURA_REPORT_FILE_PATH; \
		COBERTURA_REPORT_DIRECTORY_PATH="$$(dirname "$$COBERTURA_REPORT_FILE_PATH")"; \
		echo "$$COBERTURA_REPORT_DIRECTORY_PATH"; \
		COBERTURA_REPORT_DIRECTORY_NAME="$$(basename "$$COBERTURA_REPORT_DIRECTORY_PATH")"; \
		echo "$$COBERTURA_REPORT_DIRECTORY_NAME"; \
		COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX="$${COBERTURA_REPORT_DIRECTORY_NAME%.*}"; \
		echo "$$COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX"; \
		mkdir -p "$(COBERTURA_REPORTS_DESTINATION_DIRECTORY)"/"$$COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX" ; \
		cp "$$COBERTURA_REPORT_FILE_PATH" "$(CURDIR)"/"$(COBERTURA_REPORTS_DESTINATION_DIRECTORY)"/"$$COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX"/cobertura.xml ; \
	done

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
