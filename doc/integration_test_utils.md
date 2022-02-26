<!-- Generated with Stardoc, Do Not Edit! -->
# `integration_test_utils` API


<a id="#integration_test_utils.semantic_version_to_name"></a>

## integration_test_utils.semantic_version_to_name

<pre>
integration_test_utils.semantic_version_to_name(<a href="#integration_test_utils.semantic_version_to_name-version">version</a>)
</pre>

Converts a semantic version string (e.g. X.Y.Z) to a suitable name string (e.g. X_Y_Z).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.semantic_version_to_name-version"></a>version |  A semantic version <code>string</code>.   |  none |

**RETURNS**

A `string` that is suitable for use in a label or filename.


<a id="#integration_test_utils.bazel_binary_label"></a>

## integration_test_utils.bazel_binary_label

<pre>
integration_test_utils.bazel_binary_label(<a href="#integration_test_utils.bazel_binary_label-version">version</a>)
</pre>

Returns a label for the specified Bazel version as provided by https://github.com/bazelbuild/bazel-integration-testing.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_binary_label-version"></a>version |  A <code>string</code> value representing the semantic version of Bazel to use for the integration test.   |  none |

**RETURNS**

A `string` representing a label for a version of Bazel.


<a id="#integration_test_utils.bazel_integration_test_name"></a>

## integration_test_utils.bazel_integration_test_name

<pre>
integration_test_utils.bazel_integration_test_name(<a href="#integration_test_utils.bazel_integration_test_name-name">name</a>, <a href="#integration_test_utils.bazel_integration_test_name-version">version</a>)
</pre>

Generates a test name from the provided base name and the Bazel version.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_integration_test_name-name"></a>name |  The base name as a <code>string</code>.   |  none |
| <a id="integration_test_utils.bazel_integration_test_name-version"></a>version |  The Bazel semantic version as a <code>string</code>.   |  none |

**RETURNS**

A `string` that is suitable as an integration test name.


<a id="#integration_test_utils.bazel_integration_test_names"></a>

## integration_test_utils.bazel_integration_test_names

<pre>
integration_test_utils.bazel_integration_test_names(<a href="#integration_test_utils.bazel_integration_test_names-name">name</a>, <a href="#integration_test_utils.bazel_integration_test_names-versions">versions</a>)
</pre>

Generates a `list` of integration test names based upon the provided base name and versions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.bazel_integration_test_names-name"></a>name |  The base name as a <code>string</code>.   |  none |
| <a id="integration_test_utils.bazel_integration_test_names-versions"></a>versions |  A <code>list</code> of semantic version <code>string</code> values.   |  <code>[]</code> |

**RETURNS**

A `list` of integration test names as `string` values.


<a id="#integration_test_utils.glob_workspace_files"></a>

## integration_test_utils.glob_workspace_files

<pre>
integration_test_utils.glob_workspace_files(<a href="#integration_test_utils.glob_workspace_files-workspace_path">workspace_path</a>)
</pre>

Recursively globs the Bazel workspace files at the specified path.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="integration_test_utils.glob_workspace_files-workspace_path"></a>workspace_path |  A <code>string</code> representing the path to glob.   |  none |

**RETURNS**

A `list` of the files under the specified path ignoring certain Bazel
  artifacts (e.g. `bazel-*`).


