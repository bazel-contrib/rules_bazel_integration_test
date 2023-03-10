"""Make `bazel_binaries` public without loading files with other deps."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binaries = "bazel_binaries",
)

# Repository Rules/Macros
bazel_binaries = _bazel_binaries
