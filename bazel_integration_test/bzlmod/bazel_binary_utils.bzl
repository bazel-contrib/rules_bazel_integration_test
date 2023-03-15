"""Module for resolving repository names for Bazel binaries."""

load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

def _repo_name(version_to_repo_name, version):
    if len(version_to_repo_name) == 0:
        # Fallback to original behavior.
        return no_deps_utils.bazel_binary_repo_name(version)
    if no_deps_utils.is_version_file(version):
        version_str = str(Label(version))
    else:
        version_str = version
    repo_name = version_to_repo_name.get(version_str, None)
    if repo_name == None:
        fail("""\
Failed to find a Bazel binary registered for version '{}'.\
""".format(version))
    return repo_name

def _label(version_to_repo_name, version, canonicalize):
    repo_name = _repo_name(version_to_repo_name, version)
    return canonicalize(no_deps_utils.bazel_binary_label(repo_name))

bazel_binary_utils = struct(
    label = _label,
)
