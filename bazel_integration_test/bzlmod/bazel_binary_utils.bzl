"""Module for resolving repository names for Bazel binaries."""

load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

def _repo_name(version_to_repo_name, version):
    if len(version_to_repo_name) == 0:
        # Fallback to original behavior.
        return no_deps_utils.bazel_binary_repo_name(version)
    version_str = no_deps_utils.normalize_version(version)
    repo_name = version_to_repo_name.get(version_str, None)
    if repo_name == None:
        fail("""\
Failed to find a Bazel binary registered for version '{version}' ({version_str}).\
""".format(
            version = version,
            version_str = version_str,
        ))
    return repo_name

def _label(version_to_repo_name, version, canonicalize):
    repo_name = _repo_name(version_to_repo_name, version)
    return canonicalize(no_deps_utils.bazel_binary_label(repo_name))

bazel_binary_utils = struct(
    label = _label,
)
