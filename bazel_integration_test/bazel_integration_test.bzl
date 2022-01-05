load(
    "//bazel_integration_test/private:bazel_integration_test.bzl",
    _bazel_integration_test = "bazel_integration_test",
    _bazel_integration_tests = "bazel_integration_tests",
)
load(
    "//bazel_integration_test/private:integration_test_utils.bzl",
    _integration_test_utils = "integration_test_utils",
)
load(
    "//bazel_integration_test/private:default_test_runner.bzl",
    _default_test_runner = "default_test_runner",
)

# Macros
bazel_integration_test = _bazel_integration_test
bazel_integration_tests = _bazel_integration_tests
default_test_runner = _default_test_runner

# APIs
integration_test_utils = _integration_test_utils
