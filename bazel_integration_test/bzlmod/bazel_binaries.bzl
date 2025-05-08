"""Implementation for bzlmod `bazel_binaries`."""

load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")
load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binary_repo_rule = "bazel_binary",
    _bazelisk_binary_repo_rule = "bazelisk_binary",
    _local_bazel_binary_repo_rule = "local_bazel_binary",
)
load("//bazel_integration_test/private:bazelisks.bzl", "bazelisks")
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """\
load("@rules_bazel_integration_test//bazel_integration_test/bzlmod:bazel_binary_utils.bzl", "bazel_binary_utils")

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

_BAZEL_BINARIES_HELPER_BUILD_BAZEL = """\
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    deps = [
        "@rules_bazel_integration_test//bazel_integration_test/bzlmod:bazel_binary_utils"
    ],
    visibility = ["//visibility:public"],
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
        current_version = current_version,
        other_versions = other_versions,
        all_versions = all_versions,
    ))
    repository_ctx.file(
        "BUILD.bazel",
        _BAZEL_BINARIES_HELPER_BUILD_BAZEL,
    )
    repository_ctx.file("WORKSPACE")

_bazel_binaries_helper = repository_rule(
    implementation = _bazel_binaries_helper_impl,
    attrs = {
        "current_version": attr.string(
            doc = "The value to be used as the current version.",
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
    local = "local",
)

def _declare_bazel_binary(download, bazelisk_repo_name):
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
        _bazel_binary_repo_rule(
            name = vi.repo_name,
            version = vi.version,
            bazelisk = "@%s//:bazelisk" % bazelisk_repo_name,
        )
    else:
        vi = _version_info(
            version = str(download.version_file),
            type = _version_types.label,
            current = download.current,
        )
        _bazel_binary_repo_rule(
            name = vi.repo_name,
            version_file = download.version_file,
            bazelisk = "@%s//:bazelisk" % bazelisk_repo_name,
        )
    return vi

def _declare_local_bazel_binary(local):
    vi = _version_info(
        version = local.name,
        type = _version_types.local,
        current = local.current,
    )
    _local_bazel_binary_repo_rule(
        name = vi.repo_name,
        path = local.path,
    )
    return vi

def _bazel_binaries_impl(module_ctx):
    dep_names = []
    dev_dep_names = []

    def _add_dep_name(name, is_dev_dependency):
        if is_dev_dependency:
            dev_dep_names.append(name)
        else:
            dep_names.append(name)

    ext_is_dev_dep = not module_ctx.root_module_has_non_dev_dependency

    # Create a repository for the bazelisk binary.
    bazelisk_repo_name = "bazel_binaries_bazelisk"
    _bazelisk_binary_repo_rule(
        name = bazelisk_repo_name,
        # TODO(GH184): Make this configurable.
        version = bazelisks.DEFAULT_VERSION,
    )
    _add_dep_name(bazelisk_repo_name, is_dev_dependency = ext_is_dev_dep)

    # Create version-specific bazel repos.
    version_infos = []
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            vi = _declare_bazel_binary(download, bazelisk_repo_name)
            version_infos.append(vi)
            _add_dep_name(
                vi.repo_name,
                is_dev_dependency = module_ctx.is_dev_dependency(download),
            )
        for local in mod.tags.local:
            vi = _declare_local_bazel_binary(local)
            version_infos.append(vi)
            _add_dep_name(
                vi.repo_name,
                is_dev_dependency = module_ctx.is_dev_dependency(local),
            )

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

    bazel_binaries_repo_name = "bazel_binaries"
    _bazel_binaries_helper(
        name = bazel_binaries_repo_name,
        version_to_repo = version_to_repo,
        current_version = current_vi.version,
    )
    _add_dep_name(bazel_binaries_repo_name, is_dev_dependency = ext_is_dev_dep)

    return module_ctx.extension_metadata(
        root_module_direct_deps = dep_names,
        root_module_direct_dev_deps = dev_dep_names,
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

_local_tag = tag_class(
    attrs = {
        "current": attr.bool(
            doc = "Designate this version as the current version.",
        ),
        "name": attr.string(
            default = "local",
            doc = """\
This value is used to generate a repository name from which the local Bazel \
binary is referenced.\
""",
        ),
        "path": attr.string(
            mandatory = True,
            doc = "The path to the Bazel binary.",
        ),
    },
    doc = """\
Makes a local Bazel binary available for use in an integration test.\
""",
)

bazel_binaries = module_extension(
    implementation = _bazel_binaries_impl,
    tag_classes = {"download": _download_tag, "local": _local_tag},
    doc = """\
Provides a means for clients to download Bazel binaries for their integration \
tests.\
""",
)
