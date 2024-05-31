"""Dependencies for `mockascript`."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def mockascript_rules_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "d00f1389ee20b60018e92644e0948e16e350a7707219e7a390fb0a99b6ec9262",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.0/bazel-skylib-1.7.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.0/bazel-skylib-1.7.0.tar.gz",
        ],
    )
