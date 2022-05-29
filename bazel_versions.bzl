"""Tested/Supported Bazel Versions"""

# CURRENT_BAZEL_VERSION = ".bazelversion"
CURRENT_BAZEL_VERSION = "//:.bazelversion"
# CURRENT_BAZEL_VERSION = "//:bazel_binary_bazelversion"

OTHER_BAZEL_VERSIONS = [
    "4.2.2",
    "6.0.0-pre.20220405.2",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
