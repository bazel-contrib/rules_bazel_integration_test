load(
    "//bazel_integration_test/internal:bazel_integration_test.bzl",
    _bazel_integration_test = "bazel_integration_test",
    _bazel_integration_tests = "bazel_integration_tests",
)
load(
    "//bazel_integration_test/internal:integration_test_utils.bzl",
    _integration_test_utils = "integration_test_utils",
)

# Macros
bazel_integration_test = _bazel_integration_test
bazel_integration_tests = _bazel_integration_tests

# APIs
integration_test_utils = _integration_test_utils
