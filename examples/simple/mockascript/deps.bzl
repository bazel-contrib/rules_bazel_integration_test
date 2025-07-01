"""Dependencies for `mockascript`."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def mockascript_rules_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "fa01292859726603e3cd3a0f3f29625e68f4d2b165647c72908045027473e933",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
        ],
    )
