# Demonstrate a Custom Test Macro on top of `rules_bazel_integration_test`

This example demonstrates the implementation of a `custom_bazel_integration_test` macro.
This macro provides custom setup procedure executed before `test_runner` (it emulates behavior of
[go_bazel_test](https://github.com/bazelbuild/rules_go/blob/master/go/tools/bazel_testing/def.bzl) rule
which is used for integration testing in `rules_go`).
In particular it creates specific directories for bazel's `outputUserRoot` and for testing workspace
to speed up tests execution and set `BIT_OUTPUT_USER_ROOT` env variable available in `test_runner`.
