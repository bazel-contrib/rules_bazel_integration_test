<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to define integration tests
run against select versions of Bazel.

On this page:

  * [bazel_integration_test](#bazel_integration_test)
  * [bazel_integration_tests](#bazel_integration_tests)
  * [default_test_runner](#default_test_runner)


<a id="#bazel_integration_test"></a>

## bazel_integration_test

<pre>
bazel_integration_test(<a href="#bazel_integration_test-name">name</a>, <a href="#bazel_integration_test-test_runner">test_runner</a>, <a href="#bazel_integration_test-bazel_version">bazel_version</a>, <a href="#bazel_integration_test-bazel_binary">bazel_binary</a>, <a href="#bazel_integration_test-workspace_path">workspace_path</a>,
                       <a href="#bazel_integration_test-workspace_files">workspace_files</a>, <a href="#bazel_integration_test-tags">tags</a>, <a href="#bazel_integration_test-timeout">timeout</a>, <a href="#bazel_integration_test-env">env</a>, <a href="#bazel_integration_test-env_inherit">env_inherit</a>, <a href="#bazel_integration_test-additional_env_inherit">additional_env_inherit</a>,
                       <a href="#bazel_integration_test-kwargs">kwargs</a>)
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
| <a id="bazel_integration_test-test_runner"></a>test_runner |  A <code>Label</code> for a test runner binary. (see description for details)   |  none |
| <a id="bazel_integration_test-bazel_version"></a>bazel_version |  Optional. A <code>string</code> value representing the semantic version of Bazel to use for the integration test. If a version is not specified, then the <code>bazel_binary</code> must be specified.   |  <code>None</code> |
| <a id="bazel_integration_test-bazel_binary"></a>bazel_binary |  Optional. A <code>Label</code> for the Bazel binary to use for the execution of the integration test. Most users will not use this attribute. Use the <code>bazel_version</code> instead.   |  <code>None</code> |
| <a id="bazel_integration_test-workspace_path"></a>workspace_path |  Optional. A <code>string</code> specifying the relative path to the child workspace. If not specified, then it is derived from the name.   |  <code>None</code> |
| <a id="bazel_integration_test-workspace_files"></a>workspace_files |  Optional. A <code>list</code> of files for the child workspace. If not specified, then it is derived from the <code>workspace_path</code>.   |  <code>None</code> |
| <a id="bazel_integration_test-tags"></a>tags |  The Bazel tags to apply to the test declaration.   |  <code>["exclusive", "manual"]</code> |
| <a id="bazel_integration_test-timeout"></a>timeout |  A valid Bazel timeout value. https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner   |  <code>"long"</code> |
| <a id="bazel_integration_test-env"></a>env |  Optional. A dictionary of <code>strings</code>. Specifies additional environment variables to be passed to the test.   |  <code>{}</code> |
| <a id="bazel_integration_test-env_inherit"></a>env_inherit |  Optional. Override the env_inherit values passed to the test. Only do this if you understand what needs to be passed along. Most folks will want to use <code>additional_env_inherit</code> to pass additional env_inherit values.   |  <code>["SUDO_ASKPASS", "HOME", "CC"]</code> |
| <a id="bazel_integration_test-additional_env_inherit"></a>additional_env_inherit |  Optional. Specify additional <code>env_inherit</code> values that should be passed to the test.   |  <code>[]</code> |
| <a id="bazel_integration_test-kwargs"></a>kwargs |  additional attributes like timeout and visibility   |  none |


<a id="#bazel_integration_tests"></a>

## bazel_integration_tests

<pre>
bazel_integration_tests(<a href="#bazel_integration_tests-name">name</a>, <a href="#bazel_integration_tests-test_runner">test_runner</a>, <a href="#bazel_integration_tests-bazel_versions">bazel_versions</a>, <a href="#bazel_integration_tests-workspace_path">workspace_path</a>, <a href="#bazel_integration_tests-workspace_files">workspace_files</a>, <a href="#bazel_integration_tests-tags">tags</a>,
                        <a href="#bazel_integration_tests-timeout">timeout</a>, <a href="#bazel_integration_tests-env_inherit">env_inherit</a>, <a href="#bazel_integration_tests-additional_env_inherit">additional_env_inherit</a>, <a href="#bazel_integration_tests-kwargs">kwargs</a>)
</pre>

Macro that defines a set Bazel integration tests each executed with a different version of Bazel.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_integration_tests-name"></a>name |  name of the resulting py_test   |  none |
| <a id="bazel_integration_tests-test_runner"></a>test_runner |  A <code>Label</code> for a test runner binary.   |  none |
| <a id="bazel_integration_tests-bazel_versions"></a>bazel_versions |  A <code>list</code> of <code>string</code> string values representing the semantic versions of Bazel to use for the integration tests.   |  <code>[]</code> |
| <a id="bazel_integration_tests-workspace_path"></a>workspace_path |  A <code>string</code> specifying the path to the child workspace. If not specified, then it is derived from the name.   |  <code>None</code> |
| <a id="bazel_integration_tests-workspace_files"></a>workspace_files |  Optional. A <code>list</code> of files for the child workspace. If not specified, then it is derived from the <code>workspace_path</code>.   |  <code>None</code> |
| <a id="bazel_integration_tests-tags"></a>tags |  The Bazel tags to apply to the test declaration.   |  <code>["exclusive", "manual"]</code> |
| <a id="bazel_integration_tests-timeout"></a>timeout |  A valid Bazel timeout value. https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner   |  <code>"long"</code> |
| <a id="bazel_integration_tests-env_inherit"></a>env_inherit |  Optional. Override the env_inherit values passed to the test. Only do this if you understand what needs to be passed along. Most folks will want to use <code>additional_env_inherit</code> to pass additional env_inherit values.   |  <code>["SUDO_ASKPASS", "HOME", "CC"]</code> |
| <a id="bazel_integration_tests-additional_env_inherit"></a>additional_env_inherit |  Optional. Specify additional <code>env_inherit</code> values that should be passed to the test.   |  <code>[]</code> |
| <a id="bazel_integration_tests-kwargs"></a>kwargs |  additional attributes like timeout and visibility   |  none |


<a id="#default_test_runner"></a>

## default_test_runner

<pre>
default_test_runner(<a href="#default_test_runner-name">name</a>, <a href="#default_test_runner-bazel_cmds">bazel_cmds</a>, <a href="#default_test_runner-kwargs">kwargs</a>)
</pre>

Macro that defines a test runner that executes a set of Bazel commands against a workspace.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_runner-name"></a>name |  The name for the integration runner instance.   |  none |
| <a id="default_test_runner-bazel_cmds"></a>bazel_cmds |  A <code>list</code> of <code>string</code> values that represent arguments for Bazel.   |  <code>["info", "test //..."]</code> |
| <a id="default_test_runner-kwargs"></a>kwargs |  attributes that are passed to the <code>sh_binary</code> target.   |  none |


