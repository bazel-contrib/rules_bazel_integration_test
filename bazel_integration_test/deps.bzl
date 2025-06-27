"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "3e114424a5c7e4fd43e0133cc6ecdfe54e45ae8affa14fadd839f29901424043",
        strip_prefix = "rules_shell-0.4.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.4.0/rules_shell-v0.4.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "e6ebb696cda1a75dcaf8c49b9f0f41edfd6c7cbcbd79c65de7a61df0c225ac2a",
        urls = [
            "https://github.com/cgrindel/bazel-starlib/releases/download/v0.27.0/bazel-starlib.v0.27.0.tar.gz",
        ],
    )

    # MARK: - Python Runner

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "9f9f3b300a9264e4c77999312ce663be5dee9a56e361a1f6fe7ec60e1beef9a3",
        strip_prefix = "rules_python-1.4.1",
        url = "https://github.com/bazelbuild/rules_python/archive/1.4.1.tar.gz",
    )
