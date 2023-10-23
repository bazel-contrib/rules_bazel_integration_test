"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        ],
        sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "9090280a9cff7322e7c22062506b3273a2e880ca464e520b5c77fdfbed4e8805",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.18.1/bazel-starlib.v0.18.1.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "9d04041ac92a0985e344235f5d946f71ac543f1b1565f2cdbc9a2aaee8adf55b",
        strip_prefix = "rules_python-0.26.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.26.0.tar.gz",
    )
