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
        sha256 = "782cd9f51106d88693fb651b96bbfab71708bbdcb99a8b6d8741a24a1445908b",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.14.8/bazel-starlib.v0.14.8.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "ffc7b877c95413c82bfd5482c017edcf759a6250d8b24e82f41f3c8b8d9e287e",
        strip_prefix = "rules_python-0.19.0",
        url = "https://github.com/bazelbuild/rules_python/archive/0.19.0.tar.gz",
    )
