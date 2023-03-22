"""Public repository rules for rules_bazel_integration_test."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binaries = "bazel_binaries",
)

# Repository Rules/Macros
bazel_binaries = _bazel_binaries
