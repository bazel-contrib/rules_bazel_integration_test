load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:select_file.bzl", "select_file")
load(":integration_test_utils.bzl", "integration_test_utils")

"""Macros that define an sh_test target that is suitable for executing Bazel in \
an integration test.
"""

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/bazel_integration_test.bzl.

DEFAULT_TEST_RUNNER = "@cgrindel_rules_bazel_integration_test//bazel_integration_test/internal:integration_test_runner.sh"

def bazel_integration_test(
        name,
        bazel_version = None,
        bazel_binary = None,
        workspace_path = None,
        workspace_files = None,
        bazel_cmds = integration_test_utils.DEFAULT_BAZEL_CMDS,
        test_runner_srcs = [DEFAULT_TEST_RUNNER],
        tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
        timeout = "long",
        **kwargs):
    """Macro that defines a set of targets for a single Bazel integration test.

    Args:
        name: name of the resulting py_test
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
        bazel_cmds: A `list` of `string` values that represent arguments for
                    Bazel.
        test_runner_srcs: A `list` of shell scripts that are used as the test
                          runner.
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

    # Prepare the Bazel commands
    bazel_cmd_args = []
    for cmd in bazel_cmds:
        bazel_cmd_args.extend(["--bazel_cmd", "\"" + cmd + "\""])

    native.sh_test(
        name = name,
        srcs = test_runner_srcs,
        args = [
            "--bazel",
            "$(location :%s)" % (bazel_bin_name),
            "--workspace",
            "$(location :%s)" % (bazel_wksp_file_name),
        ] + bazel_cmd_args,
        data = [
            bazel_binary,
            bazel_bin_name,
            workspace_files_name,
            bazel_wksp_file_name,
        ],
        timeout = timeout,
        env = select({
            # Linux platforms require that CC be set to clang.
            "@platforms//os:linux": {"CC": "clang"},
            "//conditions:default": {},
        }),
        env_inherit = ["SUDO_ASKPASS"],
        tags = tags,
        **kwargs
    )

def bazel_integration_tests(
        name,
        workspace_path,
        bazel_versions = [],
        workspace_files = None,
        bazel_cmds = integration_test_utils.DEFAULT_BAZEL_CMDS,
        test_runner_srcs = [DEFAULT_TEST_RUNNER],
        timeout = "long",
        **kwargs):
    """Macro that defines a set Bazel integration tests each executed with a different version of Bazel.

    Args:
        name: name of the resulting py_test
        workspace_path: A `string` specifying the path to the child
                        workspace. If not specified, then it is derived from
                        the name.
        bazel_versions: A `list` of `string` string values representing the
                        semantic versions of Bazel to use for the integration
                        tests.
        workspace_files: Optional. A `list` of files for the child workspace.
                         If not specified, then it is derived from the
                         `workspace_path`.
        bazel_cmds: A `list` of `string` values that represent arguments for
                    Bazel.
        test_runner_srcs: A `list` of shell scripts that are used as the test
                          runner.
        timeout: A valid Bazel timeout value.
                 https://docs.bazel.build/versions/main/test-encyclopedia.html#role-of-the-test-runner
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
            bazel_version = bazel_version,
            workspace_path = workspace_path,
            workspace_files = workspace_files,
            bazel_cmds = bazel_cmds,
            test_runner_srcs = test_runner_srcs,
            timeout = timeout,
        )
