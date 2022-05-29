"""Manages the download of Bazel binaries."""

load("//bazel_integration_test/private:integration_test_utils.bzl", "integration_test_utils")

# Lovingly inspired by https://github.com/bazelbuild/bazel-integration-testing/blob/master/tools/repositories.bzl.

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

def _get_version_from_file(repository_ctx):
    version_file = repository_ctx.attr.version_file
    if repository_ctx.attr.version_file == None:
        return None
    version_file_path = repository_ctx.path(version_file)

    # Strip spaces and newlines
    return repository_ctx.read(version_file_path).strip(" \n")

def _bazel_binary_impl(repository_ctx):
    version = repository_ctx.attr.version
    if version == "":
        version = _get_version_from_file(repository_ctx)
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
A file (e.g., `.bazelversion`) that contains valid Bazel semantic version string.\
""",
        ),
    },
    implementation = _bazel_binary_impl,
    doc = """\
Download a bazel binary for integration test.

Limitation: only support Linux and macOS for now.\
""",
)

# GH026: Consider having versions be list of JSON. JSON would have version, sha256 and/or urls.

_REPO_NAME_PREFIX = "build_bazel_bazel_"

BAZELVERSION_VERSION = ".bazelversion"
BAZELVERSION_REPO_NAME = _REPO_NAME_PREFIX + "bazelversion"

def bazel_binaries(versions):
    """Download all of the specified bazel binaries.

    Args:
        versions: A `list` of Bazel versions.
    """
    for version in versions:
        name = integration_test_utils.bazel_binary_repo_name(version)
        if native.existing_rule(name):
            continue
        if integration_test_utils.is_version_file(version):
            bazel_binary(name = name, version_file = version)
        else:
            bazel_binary(name = name, version = version)

        # # If the version is ".bazelversion", we will load the
        # bazel_binary_args = {}
        # if version == BAZELVERSION_VERSION:
        #     name = BAZELVERSION_REPO_NAME
        #     bazel_binary_args = {
        #         "name": name,
        #         "version_file": version,
        #     }
        # else:
        #     name = _REPO_NAME_PREFIX + version.replace(".", "_")
        #     bazel_binary_args = {
        #         "name": name,
        #         "version": version,
        #     }
        # if not native.existing_rule(name):
        #     bazel_binary(**bazel_binary_args)
