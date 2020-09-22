import os


def linter_test_setup():
    root_dir = os.path.dirname(os.path.abspath(__file__)) + '/../../../..'
    os.environ["LINTER_RULES_PATH"] = root_dir + '/.github/linters'
    os.environ["LINT_FILES_ROOT_PATH"] = root_dir + '/.automation/test'


def print_output(output):
    for line in output.splitlines():
        print(line.encode('utf-8'))
