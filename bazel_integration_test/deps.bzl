load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "8ac3e45dc237121283d70506497ec39feb5092af9a57bfe34f7abf4a6bd2ebaa",
        strip_prefix = "bazel-starlib-0.6.0",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.6.0.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "a30abdfc7126d497a7698c29c46ea9901c6392d6ed315171a6df5ce433aa4502",
        strip_prefix = "rules_python-0.6.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.6.0.tar.gz",
    )
