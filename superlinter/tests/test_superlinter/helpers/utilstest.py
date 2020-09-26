import contextlib
import io
import os

from superlinter import SuperLinter


# Define env variables before any test case
def linter_test_setup(params=None):
    if params is None:
        params = {}
    sub_lint_root = params['sub_lint_root'] if 'sub_lint_root' in params else '/.automation/test'

    # Root path of default rules
    root_dir = '/tmp/lint' if os.path.exists('/tmp/lint') else os.path.relpath(os.path.relpath(os.path.dirname(
        os.path.abspath(__file__))) + '/../../../..')

    os.environ['VALIDATE_ALL_CODEBASE'] = 'true'
    # Root path of files to lint
    os.environ["GITHUB_WORKSPACE"] = os.environ["GITHUB_WORKSPACE"] + sub_lint_root \
        if "GITHUB_WORKSPACE" in os.environ and os.path.exists(
        os.environ["GITHUB_WORKSPACE"] + sub_lint_root) else root_dir + sub_lint_root
    assert os.path.exists(os.environ["GITHUB_WORKSPACE"]), 'GITHUB_WORKSPACE ' + os.environ[
        "GITHUB_WORKSPACE"] + ' is not a valid folder'


def print_output(output):
    if 'OUTPUT_DETAILS' in os.environ and os.environ['OUTPUT_DETAILS'] == 'detailed':
        for line in output.splitlines():
            print(line)


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


def test_get_linter_version(linter, test_self):
    version = linter.get_linter_version()
    print('[' + linter.linter_name + '] version: ' + version)
    test_self.assertFalse(version == 'ERROR', 'Returned version invalid: [' + version + ']')


def assert_is_skipped(skipped_item, output, test_self):
    test_self.assertRegex(output,
                          rf"(?<=Skipped linters:)*({skipped_item})(?=.*[\n])",
                          'No trace of skipped item ' + skipped_item + ' in log')
