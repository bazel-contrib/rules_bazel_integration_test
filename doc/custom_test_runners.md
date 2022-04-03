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
* Swift: [test runner](/examples/custom_test_runner/Sources/CustomTestRunner/BUILD.bazel),
  [usage](/examples/custom_test_runner/integration_tests/BUILD.bazel)
* Python: [test runner](/bazel_integration_test/py/test_base.py),
  [usage](/tests/py_tests/test_base_test.py)

## Implementation of a Custom Test Runner that Modifies Source Files

If an integration test needs to modify source files that are under test, it is best to create a copy
of the worksapce directory. By default, files provided to the integration test are symlinks to the
actual source files. Modifications to these files will change the actual sources!

A utility, called [`create_scratch_dir.sh`](/tools/create_scratch_dir.sh), provides a convenient way
to create a copy of a workspace directory that can be safely modified by an integration test.

To use the utility, add `@contrib_rules_bazel_integration_test//tools:create_scratch_dir` as
a dependency to your test runner binary target:

```python
sh_binary(
    name = "use_create_scratch_dir_test_runner",
    testonly = True,
    srcs = ["use_create_scratch_dir_test.sh"],
    data = [
        "@contrib_rules_bazel_integration_test//tools:create_scratch_dir",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
        "@cgrindel_bazel_starlib//shlib/lib:assertions",
    ],
)
```

In your test runner code, you will need to locate the utility. Bazel provides helper functions for
locating dependencies in shell binaries.

```bash
create_scratch_dir_sh_location=contrib_rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)
```

Create a copy of the workspace directory into a scratch directory using the utility. 

```bash
scratch_dir="$("${create_scratch_dir_sh}" --workspace "${BIT_WORKSPACE_DIR}")"
```

Change into the scratch directory, make your file modifications, and execute your tests.

```bash
# Change into scratch directory
cd "${scratch_dir}"

# Modify the files in the scratch directroy
echo "Make a meaningful change." > foo.txt

# Execute tests in the scracth directory
"${BIT_BAZEL_BINARY}" test //...
```




Examples:
* [A custom test runner that uses `create_scratch_dir.sh`](/examples/use_create_scratch_dir_test.sh) 
