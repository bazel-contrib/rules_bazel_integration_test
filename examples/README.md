# Examples for `rules_bazel_integration_test`

* [Simple](/examples/simple) - This workspace is a child workspace used to implement integration
  tests for this repository. See the [examples `BUILD.bazel` file](/examples/BUILD.bazel) for uses of 
  [`default_test_runner`](/doc/rules_and_macros_overview.md#default_test_runner), 
  [`bazel_integration_test`](/doc/rules_and_macros_overview.md#bazel_integration_test), and 
  [`bazel_integration_tests`](/doc/rules_and_macros_overview.md#bazel_integration_tests).
* [Custom Test Runner](/examples/custom_test_runner) - This workspace implements Bazel integration
  tests with a custom test runner written in [Swift](https://www.swift.org/).
* [Custom Test Rule](/examples/custom_bazel_integration_test) - This workspace implements custom macro on top of Bazel integration test which does specific setup procedure before executing test runner
