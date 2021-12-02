load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:select_file.bzl", "select_file")
load(":integration_test_utils.bzl", "integration_test_utils")

"""Macros that define an sh_test target that is suitable for executing Bazel in \
an integration test.
"""

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/bazel_integration_test.bzl.

def bazel_integration_test(
        name,
        test_runner,
        bazel_version = None,
        bazel_binary = None,
        workspace_path = None,
        workspace_files = None,
        tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
        timeout = "long",
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
        timeout: A valid Bazel timeout value.
                 https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner
        **kwargs: additional attributes like timeout and visibility
    """

    if bazel_binary == None and bazel_version == None:
        fail("The `bazel_binary` or the `bazel_version` must be specified.")
    if bazel_binary == None:
        bazel_binary = integration_test_utils.bazel_binary_label(bazel_version)

    if workspace_path == None:
        if name.endswith("_test"):
            workspace_path = name[:-len("_test")]
        else:
            workspace_path = name

    # Collect the workspace files into a filegroup
    if workspace_files == None:
        workspace_files = integration_test_utils.glob_workspace_files(workspace_path)

    workspace_files_name = name + "_sources"
    native.filegroup(
        name = workspace_files_name,
        srcs = workspace_files,
    )

    # Find the Bazel binary
    bazel_bin_name = name + "_bazel_binary"
    select_file(
        name = bazel_bin_name,
        srcs = bazel_binary,
        subpath = "bazel",
    )

    # Find the Bazel WORKSPACE file for the target workspace
    bazel_wksp_file_name = name + "_bazel_workspace_file"
    select_file(
        name = bazel_wksp_file_name,
        srcs = workspace_files_name,
        subpath = paths.join(workspace_path, "WORKSPACE"),
    )

    native.sh_test(
        name = name,
        srcs = [
            "@cgrindel_rules_bazel_integration_test//bazel_integration_test/internal:integration_test_wrapper.sh",
        ],
        args = [
            "--runner",
            "$(location %s)" % (test_runner),
            "--bazel",
            "$(location :%s)" % (bazel_bin_name),
            "--workspace",
            "$(location :%s)" % (bazel_wksp_file_name),
        ],
        data = [
            test_runner,
            bazel_binary,
            bazel_bin_name,
            workspace_files_name,
            bazel_wksp_file_name,
        ],
        deps = [
            "@bazel_tools//tools/bash/runfiles",
            "@cgrindel_bazel_shlib//lib:messages",
            "@cgrindel_bazel_shlib//lib:paths",
        ],
        timeout = timeout,
        env = select({
            # Linux platforms require that CC be set to clang.
            "@platforms//os:linux": {"CC": "clang"},
            "//conditions:default": {},
        }),
        # Inherit the following environment variables
        #   HOME: Avoid "could not get the user's cache directory: $HOME is not defined"
        #   SUDO_ASKPASS: Support executing tests that require sudo for certain steps.
        env_inherit = ["SUDO_ASKPASS", "HOME"],
        tags = tags,
        **kwargs
    )

def bazel_integration_tests(
        name,
        test_runner,
        bazel_versions = [],
        workspace_path = None,
        workspace_files = None,
        timeout = "long",
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
        timeout: A valid Bazel timeout value.
                 https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner
        **kwargs: additional attributes like timeout and visibility
    """
    if bazel_versions == []:
        fail("One or more Bazel versions must be specified.")

    if workspace_path == None:
        if name.endswith("_test"):
            workspace_path = name[:-len("_test")]
        else:
            workspace_path = name

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
            timeout = timeout,
        )
