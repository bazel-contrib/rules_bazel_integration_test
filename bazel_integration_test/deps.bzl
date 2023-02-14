"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "2c21a982f4928dafed4a4229ec25c656c56fdb98d17fb7e79928b60f828fbdd7",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.12.1/bazel-starlib.v0.12.1.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "36362b4d54fcb17342f9071e4c38d63ce83e2e57d7d5599ebdde4670b9760664",
        strip_prefix = "rules_python-0.18.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.18.0.tar.gz",
    )
