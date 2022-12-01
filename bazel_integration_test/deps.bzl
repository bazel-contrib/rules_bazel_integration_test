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
        sha256 = "42a496dddbc089c68cd72b1f20dfe6acf474c53043dafe230ec887f617c0c252",
        strip_prefix = "bazel-starlib-0.9.0",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.9.0.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "fda23c37fbacf7579f94d5e8f342d3a831140e9471b770782e83846117dd6596",
        strip_prefix = "rules_python-0.15.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.15.0.tar.gz",
    )
