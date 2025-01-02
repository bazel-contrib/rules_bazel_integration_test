<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to define integration tests
run against select versions of Bazel.

On this page:

  * [bazel_integration_test](#bazel_integration_test)
  * [bazel_integration_tests](#bazel_integration_tests)
  * [default_test_runner](#default_test_runner)


<a id="default_test_runner"></a>

## default_test_runner

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "default_test_runner")

default_test_runner(<a href="#default_test_runner-name">name</a>, <a href="#default_test_runner-bazel_cmds">bazel_cmds</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="default_test_runner-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="default_test_runner-bazel_cmds"></a>bazel_cmds |  The Bazel commands to be executed by the test runner in the test workspace.   | List of strings | optional |  `["info", "test //..."]`  |


<a id="bazel_integration_test"></a>

## bazel_integration_test

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_integration_test")

bazel_integration_test(<a href="#bazel_integration_test-name">name</a>, <a href="#bazel_integration_test-test_runner">test_runner</a>, <a href="#bazel_integration_test-bazel_version">bazel_version</a>, <a href="#bazel_integration_test-bazel_binary">bazel_binary</a>, <a href="#bazel_integration_test-workspace_path">workspace_path</a>,
                       <a href="#bazel_integration_test-workspace_files">workspace_files</a>, <a href="#bazel_integration_test-tags">tags</a>, <a href="#bazel_integration_test-timeout">timeout</a>, <a href="#bazel_integration_test-env">env</a>, <a href="#bazel_integration_test-env_inherit">env_inherit</a>, <a href="#bazel_integration_test-additional_env_inherit">additional_env_inherit</a>,
                       <a href="#bazel_integration_test-bazel_binaries">bazel_binaries</a>, <a href="#bazel_integration_test-data">data</a>, <a href="#bazel_integration_test-startup_options">startup_options</a>, <a href="#bazel_integration_test-kwargs">**kwargs</a>)
</pre>

Macro that defines a set of targets for a single Bazel integration test.

This macro accepts an exectuable target as the test runner for the
integration test. A test runner must support two flag-value pairs:
`--bazel` and `--workspace`. The `--bazel` value specifies the
Bazel binary to use in the integration test. The `--workspace` value
specifies the path of the `WORKSPACE` file.

If your integration test only consists of executing Bazel commands,  a
default test runner is provided by the `default_test_runner` macro.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_integration_test-name"></a>name |  name of the resulting py_test   |  none |
| <a id="bazel_integration_test-test_runner"></a>test_runner |  A `Label` for a test runner binary. (see description for details)   |  none |
| <a id="bazel_integration_test-bazel_version"></a>bazel_version |  Optional. A `string` value representing the semantic version of Bazel to use for the integration test. If a version is not specified, then the `bazel_binary` must be specified.   |  `None` |
| <a id="bazel_integration_test-bazel_binary"></a>bazel_binary |  Optional. A `Label` for the Bazel binary to use for the execution of the integration test. Most users will not use this attribute. Use the `bazel_version` instead.   |  `None` |
| <a id="bazel_integration_test-workspace_path"></a>workspace_path |  Optional. A `string` specifying the relative path to the child workspace. If not specified, then it is derived from the name.   |  `None` |
| <a id="bazel_integration_test-workspace_files"></a>workspace_files |  Optional. A `list` of files for the child workspace. If not specified, then it is derived from the `workspace_path`.   |  `None` |
| <a id="bazel_integration_test-tags"></a>tags |  The Bazel tags to apply to the test declaration.   |  `["exclusive", "manual"]` |
| <a id="bazel_integration_test-timeout"></a>timeout |  A valid Bazel timeout value. https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner   |  `"long"` |
| <a id="bazel_integration_test-env"></a>env |  Optional. A dictionary of `strings`. Specifies additional environment variables to be passed to the test.   |  `None` |
| <a id="bazel_integration_test-env_inherit"></a>env_inherit |  Optional. Override the env_inherit values passed to the test. Only do this if you understand what needs to be passed along. Most folks will want to use `additional_env_inherit` to pass additional env_inherit values.   |  `["SUDO_ASKPASS", "HOME", "CC"]` |
| <a id="bazel_integration_test-additional_env_inherit"></a>additional_env_inherit |  Optional. Specify additional `env_inherit` values that should be passed to the test.   |  `[]` |
| <a id="bazel_integration_test-bazel_binaries"></a>bazel_binaries |  Optional for WORKSPACE loaded repositories. Required for repositories that enable bzlmod. The value for this parameter is loaded by adding `load("@bazel_binaries//:defs.bzl", "bazel_binaries")` to your build file.   |  `None` |
| <a id="bazel_integration_test-data"></a>data |  Optional. A list of files to make present at test runtime.   |  `None` |
| <a id="bazel_integration_test-startup_options"></a>startup_options |  Optional. Flags that should be passed to Bazel as startup options using the `BIT_STARTUP_OPTIONS` environment variable.   |  `""` |
| <a id="bazel_integration_test-kwargs"></a>kwargs |  additional attributes like timeout and visibility   |  none |


<a id="bazel_integration_tests"></a>

## bazel_integration_tests

<pre>
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_integration_tests")

bazel_integration_tests(<a href="#bazel_integration_tests-name">name</a>, <a href="#bazel_integration_tests-test_runner">test_runner</a>, <a href="#bazel_integration_tests-bazel_versions">bazel_versions</a>, <a href="#bazel_integration_tests-workspace_path">workspace_path</a>, <a href="#bazel_integration_tests-workspace_files">workspace_files</a>, <a href="#bazel_integration_tests-tags">tags</a>,
                        <a href="#bazel_integration_tests-timeout">timeout</a>, <a href="#bazel_integration_tests-env_inherit">env_inherit</a>, <a href="#bazel_integration_tests-additional_env_inherit">additional_env_inherit</a>, <a href="#bazel_integration_tests-bazel_binaries">bazel_binaries</a>, <a href="#bazel_integration_tests-startup_options">startup_options</a>,
                        <a href="#bazel_integration_tests-kwargs">**kwargs</a>)
</pre>

Macro that defines a set Bazel integration tests each executed with a different version of Bazel.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_integration_tests-name"></a>name |  name of the resulting py_test   |  none |
| <a id="bazel_integration_tests-test_runner"></a>test_runner |  A `Label` for a test runner binary.   |  none |
| <a id="bazel_integration_tests-bazel_versions"></a>bazel_versions |  A `list` of `string` string values representing the semantic versions of Bazel to use for the integration tests.   |  `[]` |
| <a id="bazel_integration_tests-workspace_path"></a>workspace_path |  A `string` specifying the path to the child workspace. If not specified, then it is derived from the name.   |  `None` |
| <a id="bazel_integration_tests-workspace_files"></a>workspace_files |  Optional. A `list` of files for the child workspace. If not specified, then it is derived from the `workspace_path`.   |  `None` |
| <a id="bazel_integration_tests-tags"></a>tags |  The Bazel tags to apply to the test declaration.   |  `["exclusive", "manual"]` |
| <a id="bazel_integration_tests-timeout"></a>timeout |  A valid Bazel timeout value. https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner   |  `"long"` |
| <a id="bazel_integration_tests-env_inherit"></a>env_inherit |  Optional. Override the env_inherit values passed to the test. Only do this if you understand what needs to be passed along. Most folks will want to use `additional_env_inherit` to pass additional env_inherit values.   |  `["SUDO_ASKPASS", "HOME", "CC"]` |
| <a id="bazel_integration_tests-additional_env_inherit"></a>additional_env_inherit |  Optional. Specify additional `env_inherit` values that should be passed to the test.   |  `[]` |
| <a id="bazel_integration_tests-bazel_binaries"></a>bazel_binaries |  Optional for WORKSPACE loaded repositories. Required for repositories that enable bzlmod. The value for this parameter is loaded by adding `load("@bazel_binaries//:defs.bzl", "bazel_binaries")` to your build file.   |  `None` |
| <a id="bazel_integration_tests-startup_options"></a>startup_options |  Optional. Flags that should be passed to Bazel as startup options using the `BIT_STARTUP_OPTIONS` environment variable.   |  `""` |
| <a id="bazel_integration_tests-kwargs"></a>kwargs |  additional attributes like timeout and visibility   |  none |


