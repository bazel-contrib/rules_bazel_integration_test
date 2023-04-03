"""Implementation for `download_sample_file`, used for testing this repo itself."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _download_sample_file_impl(_mctx):
    http_file(
        name = "sample_file",
        url = "https://raw.githubusercontent.com/bazel-contrib/rules_bazel_integration_test/v0.12.0/.bazelversion",
        sha256 = "0baf36f9c3ef9d8b4833833e1d633707965c9850f69f04dd96712672b9e75cc0",
    )

download_sample_file = module_extension(
    _download_sample_file_impl,
)
