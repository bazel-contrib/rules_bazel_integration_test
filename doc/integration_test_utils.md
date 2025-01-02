<!-- Generated with Stardoc, Do Not Edit! -->
# `integration_test_utils` API


<a id="integration_test_utils.bazel_binary_label"></a>

## integration_test_utils.bazel_binary_label

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.bazel_binary_label(<a href="#integration_test_utils.bazel_binary_label-version">version</a>)
</pre>

Returns a label for the specified Bazel version as provided by https://github.com/bazelbuild/bazel-integration-testing.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_binary_label-version"></a>version |  A `string` value representing the semantic version of Bazel to use for the integration test.   |  none |

**RETURNS**

A `string` representing a label for a version of Bazel.


<a id="integration_test_utils.bazel_binary_repo_name"></a>

## integration_test_utils.bazel_binary_repo_name

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.bazel_binary_repo_name(<a href="#integration_test_utils.bazel_binary_repo_name-version">version</a>)
</pre>

Generates a Bazel binary repository name for the specified version.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_binary_repo_name-version"></a>version |  A `string` that represents a Bazel version or a label.   |  none |

**RETURNS**

A `string` that is suitable for use as a repository name.


<a id="integration_test_utils.bazel_integration_test_name"></a>

## integration_test_utils.bazel_integration_test_name

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.bazel_integration_test_name(<a href="#integration_test_utils.bazel_integration_test_name-name">name</a>, <a href="#integration_test_utils.bazel_integration_test_name-version">version</a>)
</pre>

Generates a test name from the provided base name and the Bazel version.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_integration_test_name-name"></a>name |  The base name as a `string`.   |  none |
| <a id="integration_test_utils.bazel_integration_test_name-version"></a>version |  The Bazel semantic version as a `string`.   |  none |

**RETURNS**

A `string` that is suitable as an integration test name.


<a id="integration_test_utils.bazel_integration_test_names"></a>

## integration_test_utils.bazel_integration_test_names

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.bazel_integration_test_names(<a href="#integration_test_utils.bazel_integration_test_names-name">name</a>, <a href="#integration_test_utils.bazel_integration_test_names-versions">versions</a>)
</pre>

Generates a `list` of integration test names based upon the provided base name and versions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_integration_test_names-name"></a>name |  The base name as a `string`.   |  none |
| <a id="integration_test_utils.bazel_integration_test_names-versions"></a>versions |  A `list` of semantic version `string` values.   |  `[]` |

**RETURNS**

A `list` of integration test names as `string` values.


<a id="integration_test_utils.glob_workspace_files"></a>

## integration_test_utils.glob_workspace_files

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.glob_workspace_files(<a href="#integration_test_utils.glob_workspace_files-workspace_path">workspace_path</a>)
</pre>

Recursively globs the Bazel workspace files at the specified path.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.glob_workspace_files-workspace_path"></a>workspace_path |  A `string` representing the path to glob.   |  none |

**RETURNS**

A `list` of the files under the specified path ignoring certain Bazel
  artifacts (e.g. `bazel-*`).


<a id="integration_test_utils.is_version_file"></a>

## integration_test_utils.is_version_file

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.is_version_file(<a href="#integration_test_utils.is_version_file-version">version</a>)
</pre>

Determines if the version string is a reference to a version file.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.is_version_file-version"></a>version |  A `string` that represents a Bazel version or a label.   |  none |

**RETURNS**

A `bool` the specifies whether the string is a file reference.


<a id="integration_test_utils.semantic_version_to_name"></a>

## integration_test_utils.semantic_version_to_name

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "integration_test_utils")

integration_test_utils.semantic_version_to_name(<a href="#integration_test_utils.semantic_version_to_name-version">version</a>)
</pre>

Converts a semantic version string (e.g. X.Y.Z) to a suitable name string (e.g. X_Y_Z).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.semantic_version_to_name-version"></a>version |  A semantic version `string`.   |  none |

**RETURNS**

A `string` that is suitable for use in a label or filename.


