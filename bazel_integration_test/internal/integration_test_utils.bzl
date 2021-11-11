def _semantic_version_to_name(version):
    """Converts a semantic version string (e.g. X.Y.Z) to a suitable name string (e.g. X_Y_Z).

    Args:
        version: A semantic version `string`.

    Returns:
        A `string` that is suitable for use in a label or filename.
    """
    return version.replace(".", "_")

def _bazel_binary_label(version):
    """Returns a label for the specified Bazel version as provided by https://github.com/bazelbuild/bazel-integration-testing.

    Args:
        version: A `string` value representing the semantic version of
                 Bazel to use for the integration test.

    Returns:
        A `string` representing a label for a version of Bazel.
    """
    return "@build_bazel_bazel_%s//:bazel_binary" % semantic_version_to_name(version)

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
        version = semantic_version_to_name(version),
    )

integration_test_utils = struct(
    semantic_version_to_name = _semantic_version_to_name,
    bazel_binary_label = _bazel_binary_label,
    bazel_integration_test_name = _bazel_integration_test_name,
)
