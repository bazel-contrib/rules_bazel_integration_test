"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "20721f63908879c083f94869e618ea8d4ff5edb91ff9a72a2ebee357fdbc352d",
        strip_prefix = "rules_shell-0.8.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.8.0/rules_shell-v0.8.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
        ],
        sha256 = "37cdfbc6faefea94f7b37760a305c98c08981116c2bc9e821e3b423221fad8c8",
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
        sha256 = "e11d2e1efce1589e5bdfa93986712c74fc7467a0f093143d489d2ef5ebb1ed2a",
        strip_prefix = "rules_python-2.2.0",
        url = "https://github.com/bazelbuild/rules_python/archive/2.2.0.tar.gz",
    )
