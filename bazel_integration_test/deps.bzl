"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
        ],
        sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "b9c88ac51ccaa0635621111308b85fdbb2606adb864596f9842aa5f7480cfe3a",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.19.0/bazel-starlib.v0.19.0.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "d70cd72a7a4880f0000a6346253414825c19cdd40a28289bdf67b8e6480edff8",
        strip_prefix = "rules_python-0.28.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.28.0.tar.gz",
    )
