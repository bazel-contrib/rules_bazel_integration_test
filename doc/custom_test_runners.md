# Custom Test Runners

The [`bazel_integration_test`](/doc/rules_and_macros_overview.md#bazel_integration_test) macro
supports executing tests with a custom test runner. So, if your integration tests require custom
setup code or if you would prefer to write the integration tests in a specific language, you can
create an executable target and pass it to the
[`test_runner`](/doc/rules_and_macros_overview.md#bazel_integration_test-test_runner) attribute. 

## Implementation of a Custom Test Runner

A custom test runner needs two pieces of information that can be discovered via environment
variables:

1. Location of the Bazel binary (`BIT_BAZEL_BINARY`)
2. Location of the workspace directory under test (`BIT_WORKSPACE_DIR`)

The value for each environment variable is an absolute path.

The Bazel integration test framework expects a test runner to signal success by exiting with a zero
exit code. A test runner that exits with a non-zero exit code will be considered a failed test.

Examples:
* [Custom test runner written in Swift](/examples/custom_test_runner/Sources/CustomTestRunner/BUILD.bazel), 
  [usage of Swift test runner](examples/custom_test_runner/integration_tests/BUILD.bazel)
* [Custom test runner written in Python](/bazel_integration_test/py/test_base.py), [usage of Python test
  runner](/tests/py_tests/test_base_test.py)

## Implementation of a Custom Test Runner that Modifies Source Files

If an integration test needs to modify source files that are under test, it is best to create a copy
of the worksapce directory. By default, files provided to the integration test are symlinks to the
actual source files. Modifications to these files will change the actual sources.

A utility called `create_scratch_dir.sh` provides a convenient way to create a copy of a workspace
directory that can be safely modified by an integration test.

Examples:
* [A custom test runner that uses `create_scratch_dir.sh`](/examples/use_create_scratch_dir_test.sh) 
