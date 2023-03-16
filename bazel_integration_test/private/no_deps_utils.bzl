"""Module with shared code that has no third-party dependencies."""

def _bazel_binary_repo_name(version):
    """Generates a Bazel binary repository name for the specified version.

    Args:
        version: A `string` that represents a Bazel version or a label.

    Returns:
        A `string` that is suitable for use as a repository name.
    """
    return "build_bazel_bazel_{version}".format(
        version = _normalize_version(version),
    )

def _normalize_version(version):
    """Normalizes a version string such that it can be used as part of a label.

    Args:
        version: A `string` that represents a Bazel version or a label.

    Returns:
        A 'string' that is suitable for use as a repository name or label name.
    """
    if _is_version_file(version):
        version_label = Label(version)
        parts = []
        if version_label.package != "":
            parts.append(version_label.package.replace("/", "_"))
        parts.append(version_label.name)
        normalized_version = "_".join(parts)
    else:
        normalized_version = _semantic_version_to_name(version)
    return normalized_version

def _semantic_version_to_name(version):
    """Converts a semantic version string (e.g. X.Y.Z) to a suitable name string (e.g. X_Y_Z).

    Args:
        version: A semantic version `string`.

    Returns:
        A `string` that is suitable for use in a label or filename.
    """
    return version.replace(".", "_")

def _is_version_file(version):
    """Determines if the version string is a reference to a version file.

    Args:
        version: A `string` that represents a Bazel version or a label.

    Returns:
        A `bool` the specifies whether the string is a file reference.
    """
    return version.find("//") > -1

def _bazel_binary_label(repo_name):
    return "@{repo_name}//:bazel_binary".format(repo_name = repo_name)

no_deps_utils = struct(
    bazel_binary_repo_name = _bazel_binary_repo_name,
    bazel_binary_label = _bazel_binary_label,
    is_version_file = _is_version_file,
    normalize_version = _normalize_version,
    semantic_version_to_name = _semantic_version_to_name,
)
