# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: info docker test ## Run all targets.

.PHONY: test ## Run the test suite
test: \
	info \
	validate-container-image-labels \
	docker-build-check \
	docker-dev-container-build-check \
	npm-audit \
	test-lib \
	inspec \
	lint-codebase \
	fix-codebase \
	test-default-config-files \
	lint-subset-files \
	test-non-default-home-directory \
	test-git-initial-commit \
	test-git-merge-commit-push \
	test-git-merge-commit-push-tag \
	test-log-level \
	test-use-find-and-ignore-gitignored-files \
	test-linters-expect-failure-log-level-notice \
	test-save-super-linter-output \
	test-save-super-linter-output-custom-path \
	test-save-super-linter-custom-summary \
	test-custom-gitleaks-log-level \
	test-dont-save-super-linter-log-file \
	test-dont-save-super-linter-output \
	test-linter-command-options \
	test-git-invalid-worktree \
	test-git-valid-worktree \
	test-github-push-event-multiple-commits \
	test-github-merge-group-event \
	test-runtime-dependencies-installation \
	test-linters \
	test-linters-fix-mode

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: help
help: ## Show help
	@grep -E ':.*?##(.*)$$' $(MAKEFILE_LIST) | grep -v 'MAKEFILE_LIST' | sed -E 's/^\.PHONY: *([a-zA-Z_-]+) */\1:/' | sort | awk 'BEGIN {FS = ":.*?## "; max_len = 0}; { f1[NR] = $$1; f2[NR] = $$2; if (length($$1) > max_len) { max_len = length($$1) } } END { padding = max_len + 1; for (i = 1; i <= NR; i++) { printf("\033[36m%-" padding "s\033[0m %s\n", f1[i], f2[i]) } }'


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
SUPER_LINTER_TEST_CONTAINER_URL := $(CONTAINER_IMAGE_ID)
DOCKERFILE := ''
IMAGE := $(CONTAINER_IMAGE_TARGET)

# Default to stadard
ifeq ($(IMAGE),)
IMAGE := standard
IMAGE_PREFIX :=
endif
ifeq ($(IMAGE),slim)
IMAGE_PREFIX := slim-
endif

# Default to latest
ifeq ($(SUPER_LINTER_TEST_CONTAINER_URL),)
SUPER_LINTER_TEST_CONTAINER_URL := "ghcr.io/super-linter/super-linter:${IMAGE_PREFIX}latest"
endif

ifeq ($(BUILD_DATE),)
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
endif

ifeq ($(BUILD_REVISION),)
BUILD_REVISION := $(shell git rev-parse HEAD)
endif

ifeq ($(BUILD_VERSION),)
BUILD_VERSION := $(shell git rev-parse HEAD)
endif

GITHUB_TOKEN_PATH := "$(CURDIR)/.github-personal-access-token"

ifeq ($(GITHUB_TOKEN),)
GITHUB_TOKEN="$(shell cat "${GITHUB_TOKEN_PATH}")"
endif

DEV_CONTAINER_URL := "super-linter/dev-container:latest"

ifeq ($(GITHUB_HEAD_REF),)
RELEASE_PLEASE_TARGET_BRANCH := "$(shell git branch --show-current)"
else
RELEASE_PLEASE_TARGET_BRANCH := "${GITHUB_HEAD_REF}"
endif

.PHONY: info
info: ## Gather information about the runtime environment
	echo "whoami: $$(whoami)"; \
	echo "pwd: $$(pwd)"; \
	echo "IMAGE:" $(IMAGE); \
	echo "IMAGE_PREFIX: $(IMAGE_PREFIX)"; \
	echo "Build date: ${BUILD_DATE}"; \
	echo "Build revision: ${BUILD_REVISION}"; \
	echo "Build version: ${BUILD_VERSION}"; \
	echo "SUPER_LINTER_TEST_CONTAINER_URL: $(SUPER_LINTER_TEST_CONTAINER_URL)"; \
	echo "ls -ahl:\n$$(ls -ahl)"; \
	echo "Git log:\n$$(git log --all --graph --abbrev-commit --decorate --format=oneline)" \
	docker images; \
	docker ps; \
	echo "Container image layers size:"; \
	docker history \
		--human \
		--no-trunc \
		--format "{{.Size}} {{.CreatedSince}} {{.CreatedBy}}" \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		| sort --human

.PHONY: check-github-token
check-github-token:
	@if [ ! -f "${GITHUB_TOKEN_PATH}" ]; then echo "Cannot find the file to load the GitHub access token: $(GITHUB_TOKEN_PATH). Create a readable file there, and populate it with a GitHub personal access token."; exit 1; fi

.PHONY: inspec
inspec: inspec-check ## Run InSpec tests
	DOCKER_CONTAINER_STATE="$$(docker inspect --format "{{.State.Running}}" $(SUPER_LINTER_TEST_CONTAINER_NAME) 2>/dev/null || echo "")"; \
	if [ "$$DOCKER_CONTAINER_STATE" = "true" ]; then docker kill $(SUPER_LINTER_TEST_CONTAINER_NAME); fi && \
	docker tag $(SUPER_LINTER_TEST_CONTAINER_URL) $(SUPER_LINTER_TEST_CONTAINER_NAME) && \
	SUPER_LINTER_TEST_CONTAINER_ID="$$(docker run -d --name $(SUPER_LINTER_TEST_CONTAINER_NAME) --rm -it --entrypoint /bin/ash $(SUPER_LINTER_TEST_CONTAINER_NAME) -c "while true; do sleep 1; done")" \
	&& docker run $(DOCKER_FLAGS) \
		--rm \
		-v "$(CURDIR)":/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e IMAGE=$(IMAGE) \
		-w="/workspace" \
		chef/inspec exec test/inspec/super-linter \
		--chef-license=accept \
		--diagnose \
		--log-level=debug \
		-t "docker://$${SUPER_LINTER_TEST_CONTAINER_ID}" \
	&& docker ps \
	&& docker kill $(SUPER_LINTER_TEST_CONTAINER_NAME)

.PHONY: docker
docker: docker-build-check check-github-token ## Build the container image
	DOCKER_BUILDKIT=1 docker buildx build --load \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_REVISION=$(BUILD_REVISION) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:${IMAGE_PREFIX}latest-buildcache \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-base_image \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-clang-format \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-python-builder \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-npm-builder \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-tflint-plugins \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-lintr-installer \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-powershell-installer \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-php-linters \
		--cache-from type=registry,ref=ghcr.io/super-linter/super-linter:latest-buildcache-ruby-installer \
		--secret id=GITHUB_TOKEN,src=$(GITHUB_TOKEN_PATH) \
		--target $(IMAGE) \
		-t $(SUPER_LINTER_TEST_CONTAINER_URL) .

.PHONY: docker-build-check ## Run Docker build checks against the Super-linter image
docker-build-check:
	DOCKER_BUILDKIT=1 docker buildx build --check \
	.

.PHONY: docker-pull
docker-pull: ## Pull the container image from registry
	docker pull $(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: open-shell-super-linter-container
open-shell-super-linter-container: ## Open a shell in the Super-linter container
	docker run $(DOCKER_FLAGS) \
		--interactive \
		--entrypoint /bin/bash \
		--rm \
		-v "$(CURDIR)":/tmp/lint \
		-v "$(CURDIR)/dependencies/Gemfile.lock":/Gemfile.lock \
		-v "$(CURDIR)/dependencies/Gemfile":/Gemfile \
		-v "$(CURDIR)/dependencies/package-lock.json":/package-lock.json \
		-v "$(CURDIR)/dependencies/package.json":/package.json \
		-v "$(CURDIR)/dependencies/composer/composer.json":/php-composer/composer.json \
		-v "$(CURDIR)/dependencies/composer/composer.lock":/php-composer/composer.lock \
		-v "$(CURDIR)/scripts/bash-exec.sh":/usr/bin/bash-exec \
		-v "$(CURDIR)/scripts/git-merge-conflict-markers.sh":/usr/bin/git-merge-conflict-markers \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: validate-container-image-labels
validate-container-image-labels: ## Validate container image labels
	$(CURDIR)/test/validate-docker-labels.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		$(BUILD_DATE) \
		$(BUILD_REVISION) \
		$(BUILD_VERSION)

.PHONY: npm-audit
npm-audit: ## Run npm audit to check for known vulnerable dependencies
	docker run $(DOCKER_FLAGS) \
		--entrypoint /bin/bash \
		--rm \
		-v "$(CURDIR)/dependencies/package-lock.json":/package-lock.json \
		-v "$(CURDIR)/dependencies/package.json":/package.json \
		--workdir / \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		-c "npm audit"

.PHONY: lint-codebase
lint-codebase: ## Lint the entire codebase
	docker run $(DOCKER_FLAGS) \
		-e CREATE_LOG_FILE=true \
		-e RUN_LOCAL=true \
		-e LOG_LEVEL=DEBUG \
		-e DEFAULT_BRANCH=main \
		-e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true \
		-e FILTER_REGEX_EXCLUDE=".*(/test/linters/|CHANGELOG.md|/test/data/test-repository-contents/).*" \
		-e GITLEAKS_CONFIG_FILE=".gitleaks-ignore-tests.toml" \
		-e RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES="default.json,hoge.json" \
		-e SAVE_SUPER_LINTER_OUTPUT=true \
		-e SAVE_SUPER_LINTER_SUMMARY=true \
		-e VALIDATE_ALL_CODEBASE=true \
		-v "$(CURDIR):/tmp/lint" \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

# Return an error if there are changes to commit
.PHONY: fix-codebase
fix-codebase: ## Fix and format the entire codebase
	docker run $(DOCKER_FLAGS) \
		-e CREATE_LOG_FILE=true \
		-e DEFAULT_BRANCH=main \
		-e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true \
		-e FILTER_REGEX_EXCLUDE=".*(/test/linters/|CHANGELOG.md|/test/data/test-repository-contents/).*" \
		-e FIX_GITHUB_ACTIONS_ZIZMOR=true \
		-e FIX_ENV=true \
		-e FIX_JAVASCRIPT_ES=true \
		-e FIX_JAVASCRIPT_PRETTIER=true \
		-e FIX_JSON=true \
		-e FIX_JSON_PRETTIER=true \
		-e FIX_MARKDOWN=true \
		-e FIX_MARKDOWN_PRETTIER=true \
		-e FIX_NATURAL_LANGUAGE=true \
		-e FIX_RUBY=true \
		-e FIX_SHELL_SHFMT=true \
		-e FIX_YAML_PRETTIER=true \
		-e GITLEAKS_CONFIG_FILE=".gitleaks-ignore-tests.toml" \
		-e LOG_LEVEL=DEBUG \
		-e RUN_LOCAL=true \
		-e SAVE_SUPER_LINTER_OUTPUT=true \
		-e SAVE_SUPER_LINTER_SUMMARY=true \
		-e VALIDATE_ALL_CODEBASE=true \
		-v "$(CURDIR):/tmp/lint" \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
	&& /bin/bash -c "source test/testUtils.sh; if ! CheckUnexpectedGitChanges ${CURDIR}; then exit 1; fi"


# This is a smoke test to check how much time it takes to lint only a small
# subset of files, compared to linting the whole codebase.
.PHONY: lint-subset-files
lint-subset-files: lint-subset-files-enable-only-one-type lint-subset-files-enable-expensive-io-checks

.PHONY: lint-subset-files-enable-only-one-type
lint-subset-files-enable-only-one-type: ## Lint a small subset of files in the codebase by enabling only one linter
	time docker run \
		-e RUN_LOCAL=true \
		-e LOG_LEVEL=DEBUG \
		-e DEFAULT_BRANCH=main \
		-e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true \
		-e FILTER_REGEX_EXCLUDE=".*(/test/linters/|CHANGELOG.md|/test/data/test-repository-contents/).*" \
		-e VALIDATE_ALL_CODEBASE=true \
		-e VALIDATE_MARKDOWN=true \
		-v "$(CURDIR):/tmp/lint" \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: lint-subset-files-enable-expensive-io-checks
lint-subset-files-enable-expensive-io-checks: ## Lint a small subset of files in the codebase and keep expensive I/O operations to check file types enabled
	time docker run \
		-e RUN_LOCAL=true \
		-e LOG_LEVEL=DEBUG \
		-e DEFAULT_BRANCH=main \
		-e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true \
		-e FILTER_REGEX_EXCLUDE=".*(/test/linters/|CHANGELOG.md|/test/data/test-repository-contents/).*" \
		-e VALIDATE_ALL_CODEBASE=true \
		-e VALIDATE_ARM=true \
		-e VALIDATE_CLOUDFORMATION=true \
		-e VALIDATE_KUBERNETES_KUBECONFORM=true \
		-e VALIDATE_MARKDOWN=true \
		-e VALIDATE_OPENAPI=true \
		-e VALIDATE_STATES=true \
		-v "$(CURDIR):/tmp/lint" \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-lib ## Test super-linter libs and globals
test-lib: \
	test-log \
	test-globals-languages \
	test-linter-rules \
	test-build-file-list \
	test-detect-files \
	test-github-event \
	test-setup-ssh \
	test-validation \
	test-output \
	test-linter-commands \
	test-linter-versions \
	test-update-ssl \
	test-bash-exec

.PHONY: test-log
test-log: ## Test log initialization and functions
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/logTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-globals-languages
test-globals-languages: ## Test globals/languages.sh
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/globalsLanguagesTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-globals-linter-command-options
test-globals-linter-command-options: ## Test globals/LinterCommandsOptions.sh
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/globalsLinterCommandsOptionsTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-linter-rules
test-linter-rules: ## Test linterRules.sh
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/linterRulesTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-build-file-list
test-build-file-list: ## Test buildFileList
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/buildFileListTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-detect-files
test-detect-files: ## Test detectFiles
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/detectFilesTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-github-event
test-github-event: ## Test githubEvent
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/githubEventTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-setup-ssh
test-setup-ssh: ## Test setupSSH
	@docker run \
		-e GITHUB_TOKEN=${GITHUB_TOKEN} \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/setupSSHTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-validation
test-validation: ## Test validation
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/validationTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-output
test-output: ## Test output
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/outputTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-linter-commands
test-linter-commands: ## Test linterCommands
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/linterCommandsTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-linter-versions
test-linter-versions: ## Test linterVersions
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/linterVersionsTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-update-ssl
test-update-ssl: ## Test updateSSL
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/updateSSLTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-bash-exec
test-bash-exec: ## Test bash-exec
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/bashExecTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-runtime-dependencies-installation ## Test runtime dependencies installation
test-runtime-dependencies-installation: \
	test-os-packages-installation

.PHONY: test-os-packages-installation
test-os-packages-installation: ## Test installing OS packages
	docker run \
		-v "$(CURDIR):/tmp/lint" \
		-w /tmp/lint \
		--entrypoint /tmp/lint/test/lib/osPackagesInstallationTest.sh \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

# Run this test against a small directory because we're only interested in
# loading default configuration files. The directory that we run super-linter
# against should not be .github because that includes default linter rules.
# Disable commitlint because the workspace is not a Git repository.
.PHONY: test-default-config-files
test-default-config-files: ## Test default configuration files loading
	docker run \
		-e RUN_LOCAL=true \
		-e LOG_LEVEL=DEBUG \
		-e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true \
		-e DEFAULT_BRANCH=main \
		-e USE_FIND_ALGORITHM=true \
		-e VALIDATE_GIT_COMMITLINT=false \
		-v "$(CURDIR)/.github/linters":/tmp/lint/.github/linters \
		-v "$(CURDIR)/docs":/tmp/lint \
		--rm \
		$(SUPER_LINTER_TEST_CONTAINER_URL)

.PHONY: test-non-default-home-directory
test-non-default-home-directory: ## Test a non-default HOME directory
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_non_default_home" \
		"$(IMAGE)"

.PHONY: test-linters-fix-mode
test-linters-fix-mode: ## Run the linters test suite (fix mode)
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_fix_mode" \
		"$(IMAGE)"

.PHONY: test-linters ## Run the linters test suite
test-linters: \
	test-linters-expect-success \
	test-linters-expect-failure

.PHONY: test-linters-expect-success
test-linters-expect-success: ## Run the linters test suite expecting successes
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_expect_success" \
		"$(IMAGE)"

.PHONY: test-linters-expect-failure
test-linters-expect-failure: ## Run the linters test suite expecting failures
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_expect_failure" \
		"$(IMAGE)"

.PHONY: test-log-level
test-log-level: ## Run a test to check if there are conflicts with the LOG_LEVEL variable
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_log_level" \
		"$(IMAGE)"

.PHONY: test-linters-expect-failure-log-level-notice
test-linters-expect-failure-log-level-notice: ## Run the linters test suite expecting failures with a LOG_LEVEL set to NOTICE
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_expect_failure_notice_log" \
		"$(IMAGE)"

.PHONY: test-git-initial-commit
test-git-initial-commit: ## Run super-linter against a repository that only has one commit
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_git_initial_commit" \
		"$(IMAGE)"

.PHONY: test-git-merge-commit-push
test-git-merge-commit-push: ## Run super-linter against a repository that has merge commits on a push event
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_merge_commit_push" \
		"$(IMAGE)"

.PHONY: test-git-merge-commit-push-tag
test-git-merge-commit-push-tag: ## Run super-linter against a repository that has merge commits and pushed a tag
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_merge_commit_push_tag" \
		"$(IMAGE)"

.PHONY: test-github-pr-event-multiple-commits
test-github-pr-event-multiple-commits: ## Run super-linter against a repository that simulates a pull request event with multiple commits
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_github_pr_event_multiple_commits" \
		"$(IMAGE)"

.PHONY: test-github-push-event-multiple-commits
test-github-push-event-multiple-commits: ## Run super-linter against a repository that simulates a push event with multiple commits
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_github_push_event_multiple_commits" \
		"$(IMAGE)"

.PHONY: test-github-merge-group-event
test-github-merge-group-event: ## Run super-linter against a repository that simulates a merge_group event
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_github_merge_group_event" \
		"$(IMAGE)"

.PHONY: test-use-find-and-ignore-gitignored-files
test-use-find-and-ignore-gitignored-files: ## Run super-linter with USE_FIND_ALGORITHM=true and IGNORE_GITIGNORED_FILES=true
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_use_find_and_ignore_gitignored_files" \
		"$(IMAGE)"

.PHONY: test-save-super-linter-output
test-save-super-linter-output: ## Run super-linter with SAVE_SUPER_LINTER_OUTPUT=true
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_save_super_linter_output" \
		"$(IMAGE)"

.PHONY: test-save-super-linter-output-custom-path
test-save-super-linter-output-custom-path: ## Run super-linter with SAVE_SUPER_LINTER_OUTPUT=true and save output in a custom directory
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_cases_save_super_linter_output_custom_path" \
		"$(IMAGE)"

.PHONY: test-save-super-linter-custom-summary
test-save-super-linter-custom-summary: ## Run super-linter with a custom SUPER_LINTER_SUMMARY_FILE_NAME
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_custom_summary" \
		"$(IMAGE)"

.PHONY: test-custom-gitleaks-log-level
test-custom-gitleaks-log-level: ## Run super-linter with a custom Gitleaks log level
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_gitleaks_custom_log_level" \
		"$(IMAGE)"

.PHONY: test-dont-save-super-linter-log-file
test-dont-save-super-linter-log-file: ## Run super-linter without saving the Super-linter log file
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_dont_save_super_linter_log_file" \
		"$(IMAGE)"

.PHONY: test-dont-save-super-linter-output
test-dont-save-super-linter-output: ## Run super-linter without saving Super-linter output files
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_dont_save_super_linter_output" \
		"$(IMAGE)"

.PHONY: test-linter-command-options
test-linter-command-options: ## Run super-linter passing options to linters
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_linter_command_options" \
		"$(IMAGE)"

.PHONY: test-git-invalid-worktree
test-git-invalid-worktree: ## Run super-linter against a Git repository with worktrees
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_git_invalid_worktree" \
		"$(IMAGE)"

.PHONY: test-git-valid-worktree
test-git-valid-worktree: ## Run super-linter against a Git repository with worktrees
	$(CURDIR)/test/run-super-linter-tests.sh \
		$(SUPER_LINTER_TEST_CONTAINER_URL) \
		"run_test_case_git_valid_worktree" \
		"$(IMAGE)"

.PHONY: docker-dev-container-build-check ## Run Docker build checks against the dev-container image
docker-dev-container-build-check:
	DOCKER_BUILDKIT=1 docker buildx build --check \
	"${CURDIR}/dev-dependencies"

.PHONY: build-dev-container-image
build-dev-container-image: docker-dev-container-build-check ## Build commit linter container image
	DOCKER_BUILDKIT=1 docker buildx build --load \
		--build-arg GID=$(shell id -g) \
		--build-arg UID=$(shell id -u) \
		-t ${DEV_CONTAINER_URL} "${CURDIR}/dev-dependencies"

.PHONY: release-please-dry-run
release-please-dry-run: build-dev-container-image check-github-token ## Run release-please in dry-run mode to preview the release pull request
	@echo "Running release-please against branch: ${RELEASE_PLEASE_TARGET_BRANCH}"; \
	docker run \
		-v "$(CURDIR):/source-repository" \
		--rm \
		${DEV_CONTAINER_URL} \
		release-please \
		release-pr \
		--config-file .github/release-please/release-please-config.json \
		--dry-run \
		--manifest-file .github/release-please/.release-please-manifest.json \
		--repo-url super-linter/super-linter \
		--target-branch ${RELEASE_PLEASE_TARGET_BRANCH} \
		--token "${GITHUB_TOKEN}" \
		--trace

.PHONY: open-shell-dev-container
open-shell-dev-container: build-dev-container-image ## Open a shell in the dev tools container
	docker run $(DOCKER_FLAGS) \
		--interactive \
		--entrypoint /bin/bash \
		--rm \
		-v "$(CURDIR)/dev-dependencies/package-lock.json":/app/package-lock.json \
		-v "$(CURDIR)/dev-dependencies/package.json":/app/package.json \
		$(DEV_CONTAINER_URL)
