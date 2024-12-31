"""Manages the download of Bazel binaries."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")
load(":no_deps_utils.bzl", "no_deps_utils")

# Lovingly inspired by https://github.com/bazelbuild/bazel-integration-testing/blob/master/tools/repositories.bzl.

# MARK: - Helpers

_BAZELISK_URL_TEMPLATE = "https://github.com/bazelbuild/bazelisk/releases/download/v{version}/{filename}"

def _is_linux(os_name):
    return os_name.startswith("linux")

def _is_macos(os_name):
    return os_name.startswith("mac os")

def _is_windows(os_name):
    return os_name.startswith("windows")

def _is_x86_64(arch_name):
    return arch_name.startswith("amd64") or arch_name.startswith("x86_64")

def _is_arm(arch_name):
    return arch_name.startswith("aarch64") or arch_name.startswith("arm")

def _download_bazelisk_binary(repository_ctx, version):
    os_name = repository_ctx.os.name.lower()
    arch_name = repository_ctx.os.arch.lower()

    if _is_linux(os_name) and _is_x86_64(arch_name):
        suffix = "linux-amd64"
    elif _is_linux(os_name) and _is_arm(arch_name):
        suffix = "linux-arm64"
    elif _is_macos(os_name) and _is_x86_64(arch_name):
        suffix = "darwin-amd64"
    elif _is_macos(os_name) and _is_arm(arch_name):
        suffix = "darwin-arm64"
    elif _is_windows(os_name) and _is_x86_64(arch_name):
        suffix = "windows-amd64.exe"
    elif _is_windows(os_name) and _is_arm(arch_name):
        suffix = "windows-arm64.exe"
    else:
        fail("Unrecognized os and arch. os: {}, arch: {}".format(
            os_name,
            arch_name,
        ))

    filename = "bazelisk-%s" % suffix
    url = _BAZELISK_URL_TEMPLATE.format(
        version = version,
        filename = filename,
    )
    repository_ctx.download(
        url = url,
        executable = True,
        output = "bazelisk",
    )

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

# MARK: - bazelisk_binary Repository Rule

def _bazelisk_binary_impl(repository_ctx):
    version = repository_ctx.attr.version

    _download_bazelisk_binary(repository_ctx, version)
    repository_ctx.file("WORKSPACE", "workspace(name='%s')" % repository_ctx.attr.name)
    repository_ctx.file("BUILD", """
exports_files(
    ["bazelisk"],
    visibility = ["//visibility:public"],
)""")

bazelisk_binary = repository_rule(
    attrs = {
        "version": attr.string(
            doc = """\
The Bazelisk version to download as a valid Bazel semantic version string.\
""",
        ),
    },
    implementation = _bazelisk_binary_impl,
    doc = """\
Download a bazelisk binary for integration tests.\
""",
)
# MARK: - bazel_binary Repository Rule

def _bazel_binary_impl(repository_ctx):
    version = repository_ctx.attr.version
    if version == "":
        version = get_version_from_file(repository_ctx)
    if version == None:
        fail("A `version` or `version_file` must be specified.")

    bazelisk_label = repository_ctx.attr.bazelisk

    # The runfile manifest uses a different format, so we need to convert.
    bazelisk_runfile = bazelisk_label.replace("@", "").replace("//", "/").replace(":", "")

    repository_ctx.file("WORKSPACE", "workspace(name='%s')" % repository_ctx.attr.name)
    repository_ctx.file("BUILD", """
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
sh_binary(
    name = "bazel_binary",
    srcs = ["bazel.sh"],
    data = ["{bazelisk}"],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
    ],
    visibility = ["//visibility:public"])""".format(
        bazelisk = bazelisk_label,
    ))

    repository_ctx.template(
        "bazel.sh",
        Label(":bazel_binaries_script.template"),
        substitutions = {
            "{bazelisk}": bazelisk_runfile,
            "{version}": version,
        },
        executable = True,
    )

bazel_binary = repository_rule(
    attrs = {
        "bazelisk": attr.string(
            doc = """\
The label of the bazelisk binary.
""",
        ),
        "version": attr.string(
            doc = """\
The Bazel version to download as a valid Bazel semantic version string.
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

# MARK: - local_bazel_binary Repository Rule

def _local_bazel_binary_impl(repository_ctx):
    path = repository_ctx.attr.path
    if not paths.is_absolute(path):
        path = paths.join(str(repository_ctx.workspace_root), path)

    repository_ctx.symlink(path, "bazel")
    repository_ctx.file("WORKSPACE", "workspace(name='%s')" % repository_ctx.attr.name)
    repository_ctx.file("BUILD", """
exports_files(
    ["bazel"],
    visibility = ["//visibility:public"],
)

alias(
    name = "bazel_binary",
    actual = "bazel",
    visibility = ["//visibility:public"],
)
""")

local_bazel_binary = repository_rule(
    implementation = _local_bazel_binary_impl,
    attrs = {
        "path": attr.string(
            mandatory = True,
            doc = "The path to a Bazel binary.",
        ),
    },
    doc = """\
Makes a local Bazel binary available for use in an integration test.\
""",
)

# MARK: - bazel_binaries_helper Repository Rule

_BAZEL_BINARIES_HELPER_DEFS_BZL = """\
load("@rules_bazel_integration_test//bazel_integration_test:repo_defs.bzl", "no_deps_utils")

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
    name = "defs",
    srcs = ["defs.bzl"],
    deps = [
        "@rules_bazel_integration_test//bazel_integration_test:repo_defs",
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
        bazelisk_version = "1.18.0",
        current = None,
        name = "bazel_binaries"):
    """Download the specified bazel binaries.

    This macro defines a repository for each Bazel version. It also defines a
    repository named `bazel_binaries` by default. This repository provides
    helpers functions and information about the Bazel binary versions.

    Args:
        versions: A `list` of Bazel versions.
        bazelisk_version: The version of Bazelisk to use for downloading Bazel
            binaries.
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

    # Create a repository for the bazelisk binary.
    bazelisk_repo_name = "%s_bazelisk" % name
    bazelisk_binary(
        name = bazelisk_repo_name,
        version = bazelisk_version,
    )

    for version in all_versions:
        bb_name = no_deps_utils.bazel_binary_repo_name(version)
        if native.existing_rule(bb_name):
            continue
        if no_deps_utils.is_version_file(version):
            if not current_version:
                current_version = version
            bazel_binary(
                name = bb_name,
                version_file = version,
                bazelisk = "@%s//:bazelisk" % bazelisk_repo_name,
            )
        else:
            bazel_binary(
                name = bb_name,
                version = version,
                bazelisk = "@%s//:bazelisk" % bazelisk_repo_name,
            )

    if not current_version:
        current_version = all_versions[0]
    other_versions = [v for v in all_versions if v != current_version]

    _bazel_binaries_helper(
        name = name,
        current_version = current_version,
        other_versions = other_versions,
    )
