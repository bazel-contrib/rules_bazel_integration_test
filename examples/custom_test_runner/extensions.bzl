load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _non_module_dependencies_impl(module_ctx):
    http_archive(
        name = "cgrindel_swift_bazel",
        sha256 = "434cf75cbd6c3f9bd4b750a7f9c9b5bc2cc662922d24862d559abf6ecaff8b72",
        urls = [
            "https://github.com/cgrindel/swift_bazel/releases/download/v0.3.2/swift_bazel.v0.3.2.tar.gz",
        ],
    )

non_module_dependencies = module_extension(
    implementation = _non_module_dependencies_impl,
)
