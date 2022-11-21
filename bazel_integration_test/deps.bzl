"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        ],
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "f10f9a47f23a76e6cc6f8af0b2d0c6377452e5b17ebeed6dbd656f0ba2aaa4ec",
        strip_prefix = "bazel-starlib-0.8.1",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.8.1.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "a868059c8c6dd6ad45a205cca04084c652cfe1852e6df2d5aca036f6e5438380",
        strip_prefix = "rules_python-0.14.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.14.0.tar.gz",
    )
