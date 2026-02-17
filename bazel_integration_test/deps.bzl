"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "e6b87c89bd0b27039e3af2c5da01147452f240f75d505f5b6880874f31036307",
        strip_prefix = "rules_shell-0.6.1",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.1/rules_shell-v0.6.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.0/bazel-skylib-1.9.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.0/bazel-skylib-1.9.0.tar.gz",
        ],
        sha256 = "3b5b49006181f5f8ff626ef8ddceaa95e9bb8ad294f7b5d7b11ea9f7ddaf8c59",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "5edef722277a1a69fddc3a21268c1b116fb65d2d757253f07670f3e081445bbe",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.30.0/bazel-starlib.v0.30.0.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "c85d5db38d3eac06167a13b10c9dba54b003a986cd4f1ebc00806b74e7c12f06",
        strip_prefix = "rules_python-1.8.4",
        url = "https://github.com/bazelbuild/rules_python/archive/1.8.4.tar.gz",
    )
