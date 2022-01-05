# Lovingly inspired by https://github.com/bazelbuild/bazel-integration-testing/blob/master/tools/repositories.bzl.

def _get_platform_name(rctx):
    os_name = rctx.os.name.lower()

    if os_name.startswith("mac os"):
        return "darwin-x86_64"
    if os_name.startswith("windows"):
        return "windows-x86_64"

    # We default on linux-x86_64 because we only support 3 platforms
    return "linux-x86_64"

def _is_windows(rctx):
    return _get_platform_name(rctx).startswith("windows")

def _get_installer(rctx):
    platform = _get_platform_name(rctx)
    version = rctx.attr.version

    if _is_windows(rctx):
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
            # TODO: support other forks like bazelisk does
            fork = "bazelbuild",
            version = version,
            kind = kind,
            filename = filename,
        )
        for url in enabled_packages
    ]
    args = {"url": urls, "type": "zip"}

    rctx.download_and_extract(**args)

def _bazel_repository_impl(rctx):
    _get_installer(rctx)
    rctx.file("WORKSPACE", "workspace(name='%s')" % rctx.attr.name)
    rctx.file("BUILD", """
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
            mandatory = True,
            doc = "The Bazel version to download.",
        ),
    },
    implementation = _bazel_repository_impl,
    doc = """\
Download a bazel binary for integration test.

Limitation: only support Linux and macOS for now.\
""",
)

# TODO: Consider having versions be dict with key=version and value=sha256.
# TODO: Consider having versions be list of JSON. JSON would have version, sha256 and/or urls.

def bazel_binaries(versions):
    """Download all of the specified bazel binaries.

    Args:
        versions: A `list` of Bazel versions.
    """
    for version in versions:
        name = "build_bazel_bazel_" + version.replace(".", "_")
        if not native.existing_rule(name):
            bazel_binary(name = name, version = version)
