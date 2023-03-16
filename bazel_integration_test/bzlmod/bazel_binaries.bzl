"""Implementation for bzlmod `bazel_binaries`."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binary_repo_rule = "bazel_binary",
)
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """load("@{rbt_repo_name}//bazel_integration_test/bzlmod:bazel_binary_utils.bzl", "bazel_binary_utils")

def _label(version):
    return bazel_binary_utils.label(_VERSIONS, version, lambda x: Label(x))

_VERSIONS = {versions}

bazel_binaries = struct(
    label = _label,
)
"""

def _bazel_binaries_helper_impl(repository_ctx):
    repository_ctx.file("defs.bzl", _BAZEL_BINARIES_HELPER_DEFS_BZL.format(
        versions = repository_ctx.attr.versions,
        rbt_repo_name = repository_ctx.attr.rbt_repo_name,
    ))
    repository_ctx.file("WORKSPACE")
    repository_ctx.file("BUILD.bazel")

_bazel_binaries_helper = repository_rule(
    implementation = _bazel_binaries_helper_impl,
    attrs = {
        "rbt_repo_name": attr.string(
            doc = "The name of the rules_bazel_integration_test repo.",
            mandatory = True,
        ),
        "versions": attr.string_dict(
            doc = "A mapping of version number/reference to repository name.",
            mandatory = True,
        ),
    },
    doc = "Hub repository that resolves Bazel versions to Bazel labels.",
)

# MARK: - bazel_binaries Extension

def _declare_bazel_binary(download):
    if download.version != "" and download.version_file != None:
        fail("""\
A bazel_binary.download can only have one of the following: \
version, version_file.\
""")
    if download.version != "":
        version = download.version
        repo_name = no_deps_utils.bazel_binary_repo_name(version)
        _bazel_binary_repo_rule(name = repo_name, version = version)
    else:
        version = str(download.version_file)
        repo_name = no_deps_utils.bazel_binary_repo_name(version)
        _bazel_binary_repo_rule(
            name = repo_name,
            version_file = download.version_file,
        )
    return (version, repo_name)

def _bazel_binaries_impl(module_ctx):
    rbt_repo_name = "rules_bazel_integration_test"
    version_to_repo = {}
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            version, repo_name = _declare_bazel_binary(download)
            version_to_repo[version] = repo_name
        for rbt_repo in mod.tags.rbt_repo:
            rbt_repo_name = rbt_repo.name

    _bazel_binaries_helper(
        name = "bazel_binaries",
        versions = version_to_repo,
        rbt_repo_name = rbt_repo_name,
    )

_rbt_repo_tag = tag_class(
    attrs = {
        "name": attr.string(
            doc = "The name of the rules_bazel_integration_test repository.",
        ),
    },
    doc = """\
For internal use only. Allow a client to specify the name of the \
`rules_bazel_integration_test` repository. The only repository that should use \
this tag class is `rules_bazel_integration_test`.\
""",
)

_download_tag = tag_class(
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
    doc = """\
Identifies Bazel versions that will be downloaded and made available for \
`bazel_integration_test`.\
""",
)

bazel_binaries = module_extension(
    implementation = _bazel_binaries_impl,
    tag_classes = {"download": _download_tag, "rbt_repo": _rbt_repo_tag},
    doc = """\
Provides a means for clients to download Bazel binaries for their integration \
tests.\
""",
)
