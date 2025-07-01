"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "b15cc2e698a3c553d773ff4af35eb4b3ce2983c319163707dddd9e70faaa062d",
        strip_prefix = "rules_shell-0.5.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.5.0/rules_shell-v0.5.0.tar.gz",
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
        sha256 = "7b9039c31e909cf59eeaea8ccbdc54f09f7ebaeb9609b94371c7de45e802977c",
        strip_prefix = "rules_python-1.5.0",
        url = "https://github.com/bazelbuild/rules_python/archive/1.5.0.tar.gz",
    )
