# Demonstrate a Custom Test Runner for `rules_bazel_integration_test`

This example demonstrates the implementation of a [custom test
runner](/README.md#custom-test-runner). While the default test runner is implemented using [Bash
shell scripts](/bazel_integration_test/private/default_test_runner.sh),
`rules_bazel_integration_test` supports test runners implemented in any language that can create an
executable target.  This workspace implements Bazel integration tests with a custom test runner
written in [Swift](https://www.swift.org/). Check out the [integration test
declaration](/examples/custom_test_runner/integration_tests/BUILD.bazel) for more
information.
