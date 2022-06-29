"""Macros that define an sh_test target that is suitable for executing Bazel in \
an integration test.\
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:select_file.bzl", "select_file")
load(":integration_test_utils.bzl", "integration_test_utils")

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/bazel_integration_test.bzl.

# By default, inherit the following environment variables
#   HOME: Avoid "could not get the user's cache directory: $HOME is not defined"
#   SUDO_ASKPASS: Support executing tests that require sudo for certain steps.
_DEFAULT_ENV_INHERIT = ["SUDO_ASKPASS", "HOME"]

def bazel_integration_test(
        name,
        test_runner,
        bazel_version = None,
        bazel_binary = None,
        workspace_path = None,
        workspace_files = None,
        tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
        timeout = "long",
        env = {},
        env_inherit = _DEFAULT_ENV_INHERIT,
        additional_env_inherit = [],
        **kwargs):
    """Macro that defines a set of targets for a single Bazel integration test.

    This macro accepts an exectuable target as the test runner for the
    integration test. A test runner must support two flag-value pairs:
    `--bazel` and `--workspace`. The `--bazel` value specifies the
    Bazel binary to use in the integration test. The `--workspace` value
    specifies the path of the `WORKSPACE` file.

    If your integration test only consists of executing Bazel commands,  a
    default test runner is provided by the `default_test_runner` macro.

    Args:
        name: name of the resulting py_test
        test_runner: A `Label` for a test runner binary. (see description for
                     details)
        bazel_version: Optional. A `string` value representing the semantic
                       version of Bazel to use for the integration test. If a
                       version is not specified, then the `bazel_binary` must
                       be specified.
        bazel_binary: Optional. A `Label` for the Bazel binary to use for the
                      execution of the integration test. Most users will not
                      use this attribute. Use the `bazel_version` instead.
        workspace_path: Optional. A `string` specifying the relative path to
                        the child workspace. If not specified, then it is
                        derived from the name.
        workspace_files: Optional. A `list` of files for the child workspace.
                         If not specified, then it is derived from the
                         `workspace_path`.
        tags: The Bazel tags to apply to the test declaration.
        timeout: A valid Bazel timeout value.
                 https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner
        env: Optional. A dictionary of `strings`. Specifies additional environment
                variables to be passed to the test.
        env_inherit: Optional. Override the env_inherit values passed to the
                     test. Only do this if you understand what needs to be
                     passed along. Most folks will want to use
                     `additional_env_inherit` to pass additional env_inherit
                     values.
        additional_env_inherit: Optional. Specify additional `env_inherit`
                                values that should be passed to the test.
        **kwargs: additional attributes like timeout and visibility
    """

    if bazel_binary == None and bazel_version == None:
        fail("The `bazel_binary` or the `bazel_version` must be specified.")
    if bazel_binary == None:
        bazel_binary = integration_test_utils.bazel_binary_label(bazel_version)

    # Find the Bazel binary
    bazel_bin_name = name + "_bazel_binary"
    select_file(
        name = bazel_bin_name,
        srcs = bazel_binary,
        subpath = "bazel",
    )

    args = [
        "--runner",
        "$(location %s)" % (test_runner),
        "--bazel",
        "$(location :%s)" % (bazel_bin_name),
    ]
    data = [
        test_runner,
        bazel_binary,
        bazel_bin_name,
    ]

    if workspace_files != None and workspace_path == None:
        fail("You must specify the `workspace_path` when specifying `workspace_files`.")

    if workspace_path != None:
        # Collect the workspace files into a filegroup
        if workspace_files == None:
            workspace_files = integration_test_utils.glob_workspace_files(workspace_path)

        # Define a filegroup for the workspace files.
        workspace_files_name = name + "_sources"
        native.filegroup(
            name = workspace_files_name,
            srcs = workspace_files,
        )

        # Find the Bazel WORKSPACE file for the target workspace. We need to
        # convey the actual workspace directory to the rule. The location of
        # the WORKSPACE file seems to be the best way to do this.
        bazel_wksp_file_name = name + "_bazel_workspace_file"
        select_file(
            name = bazel_wksp_file_name,
            srcs = workspace_files_name,
            subpath = paths.join(workspace_path, "WORKSPACE"),
        )

        args.extend(["--workspace", "$(location :%s)" % (bazel_wksp_file_name)])
        data.extend([workspace_files_name, bazel_wksp_file_name])

    env_inherit = env_inherit + additional_env_inherit

    native.sh_test(
        name = name,
        srcs = [
            "@contrib_rules_bazel_integration_test//bazel_integration_test/private:integration_test_wrapper.sh",
        ],
        args = args,
        data = data,
        deps = [
            "@bazel_tools//tools/bash/runfiles",
            "@cgrindel_bazel_starlib//shlib/lib:messages",
        ],
        timeout = timeout,
        env = env,
        env_inherit = env_inherit,
        tags = tags,
        **kwargs
    )

def bazel_integration_tests(
        name,
        test_runner,
        bazel_versions = [],
        workspace_path = None,
        workspace_files = None,
        tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
        timeout = "long",
        env_inherit = _DEFAULT_ENV_INHERIT,
        additional_env_inherit = [],
        **kwargs):
    """Macro that defines a set Bazel integration tests each executed with a different version of Bazel.

    Args:
        name: name of the resulting py_test
        test_runner: A `Label` for a test runner binary.
        workspace_path: A `string` specifying the path to the child
                        workspace. If not specified, then it is derived from
                        the name.
        bazel_versions: A `list` of `string` string values representing the
                        semantic versions of Bazel to use for the integration
                        tests.
        workspace_files: Optional. A `list` of files for the child workspace.
                         If not specified, then it is derived from the
                         `workspace_path`.
        tags: The Bazel tags to apply to the test declaration.
        timeout: A valid Bazel timeout value.
                 https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner
        env_inherit: Optional. Override the env_inherit values passed to the
                     test. Only do this if you understand what needs to be
                     passed along. Most folks will want to use
                     `additional_env_inherit` to pass additional env_inherit
                     values.
        additional_env_inherit: Optional. Specify additional `env_inherit`
                                values that should be passed to the test.
        **kwargs: additional attributes like timeout and visibility
    """
    if bazel_versions == []:
        fail("One or more Bazel versions must be specified.")

    for bazel_version in bazel_versions:
        bazel_integration_test(
            name = integration_test_utils.bazel_integration_test_name(
                name,
                bazel_version,
            ),
            test_runner = test_runner,
            bazel_version = bazel_version,
            workspace_path = workspace_path,
            workspace_files = workspace_files,
            tags = tags,
            timeout = timeout,
            env_inherit = env_inherit,
            additional_env_inherit = additional_env_inherit,
            **kwargs
        )
