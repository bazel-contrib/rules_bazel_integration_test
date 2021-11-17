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
        name = "cgrindel_rules_updatesrc",
        sha256 = "18eb6620ac4684c2bc722b8fe447dfaba76f73d73e2dfcaf837f542379ed9bc3",
        strip_prefix = "rules_updatesrc-0.1.0",
        urls = ["https://github.com/cgrindel/rules_updatesrc/archive/v0.1.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "cgrindel_rules_bzlformat",
        sha256 = "b45b392613092b42c4ee94051be104b990e3c8651dea17410dfd63b98957cd57",
        strip_prefix = "rules_bzlformat-0.1.0",
        urls = ["https://github.com/cgrindel/rules_bzlformat/archive/v0.1.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_doc",
        sha256 = "bae4a0f41cc5cf89f26c779fc04379f09bb290b4910b2cf206c0372ad0c8aac7",
        strip_prefix = "bazel-doc-0.1.0",
        urls = ["https://github.com/cgrindel/bazel-doc/archive/v0.1.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "build_bazel_integration_testing",
        url = "https://github.com/bazelbuild/bazel-integration-testing/archive/3a6136e8f6287b04043217d94d97ba17edcb7feb.zip",
        type = "zip",
        strip_prefix = "bazel-integration-testing-3a6136e8f6287b04043217d94d97ba17edcb7feb",
        sha256 = "bfc43a94d42e08c89a26a4711ea396a0a594bd5d55394d76aae861b299628dca",
    )

    # TODO: FIX ME
    maybe(
        native.local_repository,
        name = "cgrindel_bazel_shlib",
        path = "/Users/chuck/code/cgrindel/bazel_shlib",
    )
