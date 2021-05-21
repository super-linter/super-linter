# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: info test ## Run all targets.

.PHONY: test
test: info clean inspec kcov prepare-test-reports ## Run tests

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: info
info: ## Gather information about the runtime environment
	echo "whoami: $$(whoami)"; \
	echo "pwd: $$(pwd)"; \
	echo "ls -ahl: $$(ls -ahl)"; \
	docker images; \
	docker ps

.PHONY: kcov
kcov: ## Run kcov
	docker run --rm $(DOCKER_FLAGS) \
		--user "$$(id -u)":"$$(id -g)" \
		-v "$(CURDIR)":/workspace \
		-w="/workspace" \
		kcov/kcov \
		kcov \
		--bash-parse-files-in-dir=/workspace \
		--clean \
		--exclude-pattern=.coverage,.git \
		--include-pattern=.sh \
		/workspace/test/.coverage \
		/workspace/test/runTests.sh

COBERTURA_REPORTS_DESTINATION_DIRECTORY := "$(CURDIR)/test/reports/cobertura"

.PHONY: prepare-test-reports
prepare-test-reports: ## Prepare the test reports for consumption
	mkdir -p $(COBERTURA_REPORTS_DESTINATION_DIRECTORY); \
	COBERTURA_REPORTS="$$(find "$$(pwd)" -name 'cobertura.xml')"; \
	for COBERTURA_REPORT_FILE_PATH in $$COBERTURA_REPORTS ; do \
		COBERTURA_REPORT_DIRECTORY_PATH="$$(dirname "$$COBERTURA_REPORT_FILE_PATH")"; \
		COBERTURA_REPORT_DIRECTORY_NAME="$$(basename "$$COBERTURA_REPORT_DIRECTORY_PATH")"; \
		COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX="$${COBERTURA_REPORT_DIRECTORY_NAME%.*}"; \
		mkdir -p "$(COBERTURA_REPORTS_DESTINATION_DIRECTORY)"/"$$COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX"; \
		cp "$$COBERTURA_REPORT_FILE_PATH" "$(COBERTURA_REPORTS_DESTINATION_DIRECTORY)"/"$$COBERTURA_REPORT_DIRECTORY_NAME_NO_SUFFIX"/cobertura.xml; \
	done

.PHONY: clean
clean: ## Clean the workspace
	rm -rf $(CURDIR)/test/.coverage; \
	rm -rf $(CURDIR)/test/reports

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: inspec-check
inspec-check: ## Validate inspec profiles
	docker run $(DOCKER_FLAGS) \
		--rm \
		-v "$(CURDIR)":/workspace \
		-w="/workspace" \
		chef/inspec check \
		--chef-license=accept \
		test/inspec/super-linter

SUPER_LINTER_TEST_CONTAINER_NAME := "super-linter-test"
SUPER_LINTER_TEST_CONTINER_URL := ''
DOCKERFILE := ''
IMAGE := ''
ifeq ($(IMAGE),slim)
	SUPER_LINTER_TEST_CONTINER_URL := "ghcr.io/github/super-linter:slim-test"
	DOCKERFILE := "Dockerfile-slim"
	IMAGE := "slim"
else
	SUPER_LINTER_TEST_CONTINER_URL := "ghcr.io/github/super-linter:test"
	DOCKERFILE := "Dockerfile"
	IMAGE := "standard"
endif

.PHONY: inspec
inspec: inspec-check ## Run InSpec tests
	DOCKER_CONTAINER_STATE="$$(docker inspect --format "{{.State.Running}}" "$(SUPER_LINTER_TEST_CONTAINER_NAME)" 2>/dev/null || echo "")"; \
	if [ "$$DOCKER_CONTAINER_STATE" = "true" ]; then docker kill "$(SUPER_LINTER_TEST_CONTAINER_NAME)"; fi && \
	docker build -t $(SUPER_LINTER_TEST_CONTAINER_NAME) -f $(DOCKERFILE) . && \
	SUPER_LINTER_TEST_CONTAINER_ID="$$(docker run -d --name "$(SUPER_LINTER_TEST_CONTAINER_NAME)" --rm -it --entrypoint /bin/ash "$(SUPER_LINTER_TEST_CONTAINER_NAME)" -c "while true; do sleep 1; done")" \
	&& docker run $(DOCKER_FLAGS) \
		--rm \
		-v "$(CURDIR)":/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e IMAGE=$(IMAGE) \
		-w="/workspace" \
		chef/inspec exec test/inspec/super-linter\
		--chef-license=accept \
		--diagnose \
		--log-level=debug \
		-t "docker://$${SUPER_LINTER_TEST_CONTAINER_ID}" \
	&& docker ps \
	&& docker kill "$(SUPER_LINTER_TEST_CONTAINER_NAME)"
