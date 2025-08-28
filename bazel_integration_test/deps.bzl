"""Dependencies for rules_bazel_integration_test."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_integration_test_rules_dependencies():
    """Declares the dependencies for `rules_bazel_integration_test`."""
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "fce2a7a974aa70e9367068122e19c39a6a27a5aca30698bcf9030beb529612b6",
        strip_prefix = "rules_shell-0.6.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.0/rules_shell-v0.6.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.1/bazel-skylib-1.8.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.1/bazel-skylib-1.8.1.tar.gz",
        ],
        sha256 = "51b5105a760b353773f904d2bbc5e664d0987fbaf22265164de65d43e910d8ac",
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
        sha256 = "13671d304cfe43350302213a60d93a5fc0b763b0a6de17397e3e239253b61b73",
        strip_prefix = "rules_python-1.5.4",
        url = "https://github.com/bazelbuild/rules_python/archive/1.5.4.tar.gz",
    )
