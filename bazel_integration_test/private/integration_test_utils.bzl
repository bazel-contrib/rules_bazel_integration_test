"""Utilities for naming and defining Bazel integration tests."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(":no_deps_utils.bzl", "no_deps_utils")

# MARK: - Name Functions

def _bazel_binary_label(version):
    """Returns a label for the specified Bazel version as provided by https://github.com/bazelbuild/bazel-integration-testing.

    Args:
        version: A `string` value representing the semantic version of
                 Bazel to use for the integration test.

    Returns:
        A `string` representing a label for a version of Bazel.
    """
    repo_name = no_deps_utils.bazel_binary_repo_name(version)
    return no_deps_utils.bazel_binary_label(repo_name)

def _bazel_integration_test_name(name, version):
    """Generates a test name from the provided base name and the Bazel version.

    Args:
        name: The base name as a `string`.
        version: The Bazel semantic version as a `string`.

    Returns:
        A `string` that is suitable as an integration test name.
    """
    return "{name}_bazel_{version}".format(
        name = name,
        version = no_deps_utils.format_version_for_label(version),
    )

def _bazel_integration_test_names(name, versions = []):
    """Generates a `list` of integration test names based upon the provided base name and versions.

    Args:
        name: The base name as a `string`.
        versions: A `list` of semantic version `string` values.

    Returns:
        A `list` of integration test names as `string` values.
    """
    return [
        _bazel_integration_test_name(name, version)
        for version in versions
    ]

# MARK: - Glob Functions

def _glob_workspace_files(workspace_path):
    """Recursively globs the Bazel workspace files at the specified path.

    Args:
        workspace_path: A `string` representing the path to glob.

    Returns:
        A `list` of the files under the specified path ignoring certain Bazel
        artifacts (e.g. `bazel-*`).
    """
    return native.glob(
        [paths.join(workspace_path, "**", "*")],
        exclude = [paths.join(workspace_path, "bazel-*", "**")],
    )

# MARK: - Constants

_DEFAULT_BAZEL_CMDS = ["info", "test //..."]

_DEFAULT_INTEGRATION_TEST_TAGS = [
    "exclusive",
    "manual",
]

integration_test_utils = struct(
    bazel_binary_label = _bazel_binary_label,
    bazel_binary_repo_name = no_deps_utils.bazel_binary_repo_name,
    bazel_integration_test_name = _bazel_integration_test_name,
    bazel_integration_test_names = _bazel_integration_test_names,
    glob_workspace_files = _glob_workspace_files,
    is_version_file = no_deps_utils.is_version_file,
    semantic_version_to_name = no_deps_utils.semantic_version_to_name,
    DEFAULT_BAZEL_CMDS = _DEFAULT_BAZEL_CMDS,
    DEFAULT_INTEGRATION_TEST_TAGS = _DEFAULT_INTEGRATION_TEST_TAGS,
)
