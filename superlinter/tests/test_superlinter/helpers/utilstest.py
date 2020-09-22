import os


def linter_test_setup():
    root_dir = '/action' if os.path.exists('/action') else os.path.dirname(
        os.path.abspath(__file__)) + '/../../../..'
    os.environ["GITHUB_WORKSPACE"] = root_dir + '/.automation/test'
    os.environ["LINTER_RULES_PATH"] = root_dir + '/.github/linters'


def print_output(output):
    for line in output.splitlines():
        print(line.encode('utf-8'))
