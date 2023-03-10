"""Extensions for bzlmod."""

# load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# def _non_module_dependencies_impl(_ctx):
#     http_archive(
#         name = "cgrindel_bazel_starlib",
#         sha256 = "ef07f9c12084de99f491b48670af304e2e57885e51e9113b79e221197847e56e",
#         urls = [
#             "https://github.com/cgrindel/bazel-starlib/releases/download/v0.13.1/bazel-starlib.v0.13.1.tar.gz",
#         ],
#     )

# non_module_dependencies = module_extension(
#     implementation = _non_module_dependencies_impl,
# )
