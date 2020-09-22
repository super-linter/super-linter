import contextlib
import io
import os

from superlinter import SuperLinter


def linter_test_setup():
    root_dir = '/action' if os.path.exists('/action') else os.path.dirname(
        os.path.abspath(__file__)) + '/../../../..'
    os.environ["LINTER_RULES_PATH"] = root_dir + '/lib/.automation' if os.path.exists(
        root_dir + '/lib/.automation') else root_dir + '/.github/linters'
    os.environ["GITHUB_WORKSPACE"] = root_dir + '/.automation/test' if os.path.exists(
        root_dir + '/.automation/test') else '/tmp/lint'


def print_output(output):
    for line in output.splitlines():
        print(line.encode('utf-8'))


def call_super_linter(env_vars=None):
    if env_vars is None:
        env_vars = {}
    prev_environ = os.environ.copy()
    usage_stdout = io.StringIO()
    with contextlib.redirect_stdout(usage_stdout):
        # Set env variables
        for env_var_key, env_var_value in env_vars.items():
            os.environ[env_var_key] = env_var_value
        # Call linter
        super_linter = SuperLinter()
        super_linter.run()
        # Set back env variable previous values
        for env_var_key, env_var_value in env_vars.items():
            if env_var_key in prev_environ:
                os.environ[env_var_key] = prev_environ[env_var_key]
            else:
                del os.environ[env_var_key]
    output = usage_stdout.getvalue().strip()
    print_output(output)
    return super_linter, output


def test_linter_success(linter, test_self):
    test_folder = linter.test_folder
    linter_name = linter.linter_name
    super_linter, output = call_super_linter(
        {'GITHUB_WORKSPACE': os.environ["GITHUB_WORKSPACE"] + '/' + test_folder,
         'FILTER_REGEX_INCLUDE': '.*good.*'})
    test_self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
    test_self.assertRegex(output, rf"File:\[.*good.*] was linted with \[{linter_name}\] successfully")


def test_linter_failure(linter, test_self):
    test_folder = linter.test_folder
    linter_name = linter.linter_name
    super_linter, output = call_super_linter(
        {'GITHUB_WORKSPACE': os.environ["GITHUB_WORKSPACE"] + '/' + test_folder,
         'FILTER_REGEX_INCLUDE': '.*bad.*'})
    test_self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
    test_self.assertRegex(output, rf"File:\[.*bad.*] contains error\(s\) according to \[{linter_name}\]")
    test_self.assertNotRegex(output, rf"File:\[.*bad.*] was linted with \[{linter_name}\] successfully")
