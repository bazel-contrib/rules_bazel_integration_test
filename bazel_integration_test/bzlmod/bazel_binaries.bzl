"""Implementation for bzlmod `bazel_binaries`."""

load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")
load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binary_repo_rule = "bazel_binary",
)
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """load("@{rbt_repo_name}//bazel_integration_test/bzlmod:bazel_binary_utils.bzl", "bazel_binary_utils")

def _label(version):
    return bazel_binary_utils.label(_VERSION_TO_REPO, version, lambda x: Label(x))

_VERSION_TO_REPO = {version_to_repo}

_versions = struct(
    current = "{current_version}",
    other = {other_versions},
    all = {all_versions}
)

bazel_binaries = struct(
    label = _label,
    versions = _versions,
)
"""

def _bazel_binaries_helper_impl(repository_ctx):
    current_version = repository_ctx.attr.current_version
    version_to_repo = repository_ctx.attr.version_to_repo
    if current_version == "":
        fail("A current version must be specified.")
    if version_to_repo.get(current_version) == None:
        fail("""\
The specified current version ({}) is not in the `version_to_repo` dict.\
""".format(current_version))

    all_versions = sorted(version_to_repo.keys())
    other_versions = [v for v in all_versions if v != current_version]
    repository_ctx.file("defs.bzl", _BAZEL_BINARIES_HELPER_DEFS_BZL.format(
        version_to_repo = repository_ctx.attr.version_to_repo,
        rbt_repo_name = repository_ctx.attr.rbt_repo_name,
        current_version = current_version,
        other_versions = other_versions,
        all_versions = all_versions,
    ))
    repository_ctx.file("WORKSPACE")
    repository_ctx.file("BUILD.bazel")

_bazel_binaries_helper = repository_rule(
    implementation = _bazel_binaries_helper_impl,
    attrs = {
        "current_version": attr.string(
            doc = "The value to be used as the current version.",
            mandatory = True,
        ),
        "rbt_repo_name": attr.string(
            doc = "The name of the rules_bazel_integration_test repo.",
            mandatory = True,
        ),
        "version_to_repo": attr.string_dict(
            doc = "A mapping of version number/reference to repository name.",
            mandatory = True,
        ),
    },
    doc = "Hub repository that resolves Bazel versions to Bazel labels.",
)

# MARK: - bazel_binaries Extension

def _version_info(version, type, current):
    return struct(
        version = version,
        repo_name = no_deps_utils.bazel_binary_repo_name(version),
        type = type,
        current = current,
    )

_version_types = struct(
    string = "string",
    label = "label",
)

def _declare_bazel_binary(download):
    if download.version != "" and download.version_file != None:
        fail("""\
A bazel_binary.download can only have one of the following: \
version, version_file.\
""")
    if download.version != "":
        vi = _version_info(
            version = download.version,
            type = _version_types.string,
            current = download.current,
        )
        _bazel_binary_repo_rule(name = vi.repo_name, version = vi.version)
    else:
        vi = _version_info(
            version = str(download.version_file),
            type = _version_types.label,
            current = download.current,
        )
        _bazel_binary_repo_rule(
            name = vi.repo_name,
            version_file = download.version_file,
        )
    return vi

def _bazel_binaries_impl(module_ctx):
    rbt_repo_name = "rules_bazel_integration_test"
    version_infos = []
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            vi = _declare_bazel_binary(download)
            version_infos.append(vi)
        for rbt_repo in mod.tags.rbt_repo:
            rbt_repo_name = rbt_repo.name

    if len(version_infos) == 0:
        fail("No versions were specified.")

    version_to_repo = {vi.version: vi.repo_name for vi in version_infos}
    current_vi = lists.find(version_infos, lambda x: x.current)
    if current_vi == None:
        current_vi = lists.find(
            version_infos,
            lambda x: x.type == _version_types.label,
        )
        if current_vi == None:
            current_vi = version_infos[0]

    _bazel_binaries_helper(
        name = "bazel_binaries",
        version_to_repo = version_to_repo,
        rbt_repo_name = rbt_repo_name,
        current_version = current_vi.version,
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
        "current": attr.bool(
            doc = "Designate this version as the current version.",
        ),
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
