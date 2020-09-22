import os


def linter_test_setup():
    root_dir = '/action' if os.path.exists('/action') else os.path.dirname(
        os.path.abspath(__file__)) + '/../../../..'
    os.environ["LINTER_RULES_PATH"] = root_dir + '/lib/.automation' if os.path.exists(root_dir + '/lib/.automation') else root_dir + '/.github/linters'
    os.environ["GITHUB_WORKSPACE"] = root_dir + '/.automation/test' if os.path.exists(root_dir + '/.automation/test') else '/tmp/lint'


def print_output(output):
    for line in output.splitlines():
        print(line.encode('utf-8'))
