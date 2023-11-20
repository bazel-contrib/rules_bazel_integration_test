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
        sha256 = "9090280a9cff7322e7c22062506b3273a2e880ca464e520b5c77fdfbed4e8805",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.18.1/bazel-starlib.v0.18.1.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "9acc0944c94adb23fba1c9988b48768b1bacc6583b52a2586895c5b7491e2e31",
        strip_prefix = "rules_python-0.27.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.27.0.tar.gz",
    )
