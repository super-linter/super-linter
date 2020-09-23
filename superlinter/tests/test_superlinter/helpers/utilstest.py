import contextlib
import io
import os

from superlinter import SuperLinter


# Define env variables before any test case
def linter_test_setup():
    # Root path of default rules
    root_dir = '/action' if os.path.exists('/action') else os.path.dirname(
        os.path.abspath(__file__)) + '/../../../..'
    os.environ["LINTER_RULES_PATH"] = root_dir + '/lib/.automation' if os.path.exists(
        root_dir + '/lib/.automation') else root_dir + '/.github/linters'
    assert os.path.exists(os.environ["LINTER_RULES_PATH"]), 'LINTER_RULES_PATH ' + os.environ[
        "LINTER_RULES_PATH"] + ' is a valid folder'

    # Root path of files to lint
    os.environ["GITHUB_WORKSPACE"] = '/tmp/lint/.automation/test' if os.path.exists(
        '/tmp/lint/.automation/test') else root_dir + '/.automation/test'
    assert os.path.exists(os.environ["GITHUB_WORKSPACE"]), 'GITHUB_WORKSPACE ' + os.environ[
        "GITHUB_WORKSPACE"] + ' is a valid folder'


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
    env_vars = {'GITHUB_WORKSPACE': os.environ["GITHUB_WORKSPACE"] + '/' + test_folder,
                'FILTER_REGEX_INCLUDE': "(.*_good_.*|.*\\/good\\/.*)",
                'LOG_LEVEL': 'DEBUG'}
    linter_key = "VALIDATE_" + linter.name
    env_vars[linter_key] = 'true'
    super_linter, output = call_super_linter(env_vars)
    test_self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
    if len(linter.file_names) > 0 and len(linter.file_extensions) == 0:
        test_self.assertRegex(output, rf"File:\[{linter.file_names[0]}] was linted with \[{linter_name}\] successfully")
    else:
        test_self.assertRegex(output, rf"File:\[.*good.*] was linted with \[{linter_name}\] successfully")


def test_linter_failure(linter, test_self):
    test_folder = linter.test_folder
    linter_name = linter.linter_name
    env_vars = {'GITHUB_WORKSPACE': os.environ["GITHUB_WORKSPACE"] + '/' + test_folder,
                'FILTER_REGEX_INCLUDE': '(.*_bad_.*|.*\\/bad\\/.*)',
                'LOG_LEVEL': 'DEBUG'
                }
    linter_key = "VALIDATE_" + linter.name
    env_vars[linter_key] = 'true'
    super_linter, output = call_super_linter(env_vars)
    test_self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
    if len(linter.file_names) > 0 and len(linter.file_extensions) == 0:
        test_self.assertRegex(output,
                              rf"File:\[{linter.file_names[0]}] contains error\(s\) according to \[{linter_name}\]")
        test_self.assertNotRegex(output,
                                 rf"File:\[{linter.file_names[0]}] was linted with \[{linter_name}\] successfully")
    else:
        test_self.assertRegex(output, rf"File:\[.*bad.*] contains error\(s\) according to \[{linter_name}\]")
        test_self.assertNotRegex(output, rf"File:\[.*bad.*] was linted with \[{linter_name}\] successfully")
