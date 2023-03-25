"""Public repository rules for rules_bazel_integration_test."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binaries = "bazel_binaries",
)
load(
    "//bazel_integration_test/private:no_deps_utils.bzl",
    _no_deps_utils = "no_deps_utils",
)

# Repository Rules/Macros
bazel_binaries = _bazel_binaries
no_deps_utils = _no_deps_utils
