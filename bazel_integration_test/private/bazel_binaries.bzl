"""Manages the download of Bazel binaries."""

load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")
load(":no_deps_utils.bzl", "no_deps_utils")

# Lovingly inspired by https://github.com/bazelbuild/bazel-integration-testing/blob/master/tools/repositories.bzl.

# MARK: - Helpers

def _get_platform_name(repository_ctx):
    os_name = repository_ctx.os.name.lower()

    if os_name.startswith("mac os"):
        return "darwin-x86_64"
    if os_name.startswith("windows"):
        return "windows-x86_64"

    # We default on linux-x86_64 because we only support 3 platforms
    return "linux-x86_64"

def _is_windows(repository_ctx):
    return _get_platform_name(repository_ctx).startswith("windows")

def _get_installer(repository_ctx, version):
    platform = _get_platform_name(repository_ctx)

    if _is_windows(repository_ctx):
        extension = "zip"
        installer = ""
    else:
        extension = "sh"
        installer = "-installer"

    filename = "bazel-{version}{installer}-{platform}.{extension}".format(
        version = version,
        installer = installer,
        platform = platform,
        extension = extension,
    )

    kind = "release"

    # Mimics determineURL in github.com/bazelbuild/bazelisk/bazelisk.go
    enabled_packages = [
        "https://releases.bazel.build/{version}/{kind}/{filename}",
    ]

    if "rc" in version:
        version_components = version.split("rc")
        version = version_components[0]
        kind = "rc" + version_components[1]
    else:
        enabled_packages.append(
            "https://github.com/{fork}/bazel/releases/download/{version}/{filename}",
        )

    urls = [
        url.format(
            fork = "bazelbuild",
            version = version,
            kind = kind,
            filename = filename,
        )
        for url in enabled_packages
    ]
    args = {"type": "zip", "url": urls}

    repository_ctx.download_and_extract(**args)

def get_version_from_file(repository_ctx):
    """Read the Bazel version string from the version file.

    Args:
      repository_ctx: Repository rule context object.

    Returns:
      The first non-empty line of the file with surrounding white space stripped.
    """
    version_file = repository_ctx.attr.version_file
    if repository_ctx.attr.version_file == None:
        return None
    version_file_path = repository_ctx.path(version_file)

    # Strip spaces and newlines
    return (
        repository_ctx
            .read(version_file_path)
            .lstrip(" \n")  # strip leading white space
            .partition("\n")[0]  # read the first nonempty line
            .rstrip(" \n")  # strip trailing white space
    )

# MARK: - bazel_binary Repository Rule

def _bazel_binary_impl(repository_ctx):
    version = repository_ctx.attr.version
    if version == "":
        version = get_version_from_file(repository_ctx)
    if version == None:
        fail("A `version` or `version_file` must be specified.")

    _get_installer(repository_ctx, version)
    repository_ctx.file("WORKSPACE", "workspace(name='%s')" % repository_ctx.attr.name)
    repository_ctx.file("BUILD", """
filegroup(
  name = "bazel_binary",
  srcs = select({
    "@bazel_tools//src/conditions:windows" : ["bazel.exe"],
    "//conditions:default": ["bazel-real","bazel"],
  }),
  visibility = ["//visibility:public"])""")

bazel_binary = repository_rule(
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
    implementation = _bazel_binary_impl,
    doc = """\
Download a bazel binary for integration test.\
""",
)

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """\
load(":no_deps_utils.bzl", "no_deps_utils")

_versions = struct(
    current = "{current_version}",
    other = {other_versions},
    all = {all_versions}
)

bazel_binaries = struct(
    label = no_deps_utils.bazel_binary_label_from_version,
    versions = _versions,
)
"""

_BAZEL_BINARIES_HELPER_BUILD_BAZEL = """\
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "no_deps_utils",
    srcs = ["no_deps_utils.bzl"],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    deps = [
        ":no_deps_utils",
    ],
    visibility = ["//visibility:public"],
)
"""

def _bazel_binaries_helper_impl(repository_ctx):
    current_version = repository_ctx.attr.current_version
    other_versions = repository_ctx.attr.other_versions
    all_versions = []
    if current_version != "":
        all_versions.append(current_version)
    all_versions.extend(other_versions)
    if len(all_versions) == 0:
        fail("No versions were specified.")
    repository_ctx.file("defs.bzl", _BAZEL_BINARIES_HELPER_DEFS_BZL.format(
        current_version = current_version,
        other_versions = other_versions,
        all_versions = all_versions,
    ))
    repository_ctx.file(
        "no_deps_utils.bzl",
        repository_ctx.read(Label("//bazel_integration_test/private:no_deps_utils.bzl")),
    )
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
        ),
        "other_versions": attr.string_list(
            doc = "The values to be used as the other versions.",
        ),
    },
    doc = """\
Provides a default implementation for a `bazel_binaries` repository for clients \
that load dependencies via the `WORKSPACE`.\
""",
)

# MARK: - bazel-binaries Macro

def bazel_binaries(
        versions,
        current = None,
        name = "bazel_binaries"):
    """Download the specified bazel binaries.

    This macro defines a repository for each Bazel version. It also defines a
    repository named `bazel_binaries` by default. This repository provides
    helpers functions and information about the Bazel binary versions.

    Args:
        versions: A `list` of Bazel versions.
        current: Optional. The version that is considered the current version.
            If not specified, a reference to a `.bazelversion` will be
            considered the current version.
        name: Optional. The name of the repository that provides helper
            functions and version information about the Bazel binaries.
    """
    all_versions = list(versions)
    if current != None and not lists.contains(all_versions, current):
        all_versions.append(current)
    current_version = current if current else ""

    for version in all_versions:
        bb_name = no_deps_utils.bazel_binary_repo_name(version)
        if native.existing_rule(bb_name):
            continue
        if no_deps_utils.is_version_file(version):
            if not current_version:
                current_version = version
            bazel_binary(name = bb_name, version_file = version)
        else:
            bazel_binary(name = bb_name, version = version)

    other_versions = [v for v in all_versions if v != current_version]

    _bazel_binaries_helper(
        name = name,
        current_version = current_version,
        other_versions = other_versions,
    )
