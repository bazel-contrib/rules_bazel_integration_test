"""Tested/Supported Bazel Versions"""

CURRENT_BAZEL_VERSION = "//:.bazelversion"

OTHER_BAZEL_VERSIONS = [
    "6.0.0-pre.20221020.1",
    "7.0.0-pre.20221026.2",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
