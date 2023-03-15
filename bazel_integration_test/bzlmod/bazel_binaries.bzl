"""Implementation for bzlmod `bazel_binaries`."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binary_repo_rule = "bazel_binary",
)
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """load("@rule_bazel_integration_test//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

def repo_name(version):
    return no_deps_utils.bazel_binary_repo_name(version)

_VERSIONS = {}
"""

def _bazel_binaries_helper_impl(repository_ctx):
    pass

_bazel_binaries_helper = repository_rule(
    implementation = _bazel_binaries_helper_impl,
    attrs = {
        "versions": attr.string_dict(
            doc = "A mapping of version number/reference to repository name.",
            mandatory = True,
        ),
    },
)

# MARK: - bazel_binaries Extension

def _declare_bazel_binary(download):
    if download.version != "" and download.version_file != None:
        fail("""\
A bazel_binary.download can only have one of the following: \
version, version_file.\
""")
    if download.version != "":
        _bazel_binary_repo_rule(
            name = no_deps_utils.bazel_binary_repo_name(download.version),
            version = download.version,
        )
    else:
        _bazel_binary_repo_rule(
            name = no_deps_utils.bazel_binary_repo_name(str(download.version_file)),
            version_file = download.version_file,
        )

def _bazel_binaries_impl(module_ctx):
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            _declare_bazel_binary(download)

_download = tag_class(
    attrs = {
        "version": attr.string(
            doc = """\
The Bazel version to download as a valid Bazel semantic version string.\
""",
        ),
        "version_file": attr.label(
            allow_single_file = True,
            doc = """\
A file (e.g., `//:.bazelversion`) that contains a valid Bazel semantic version \
string.\
""",
        ),
    },
)

bazel_binaries = module_extension(
    implementation = _bazel_binaries_impl,
    tag_classes = {"download": _download},
)
