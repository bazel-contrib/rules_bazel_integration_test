"""Defines the default test runner for integration tests."""

load("@cgrindel_bazel_starlib//shlib/rules:execute_binary.bzl", "execute_binary")
load(":integration_test_utils.bzl", "integration_test_utils")

def default_test_runner(
        name,
        bazel_cmds = integration_test_utils.DEFAULT_BAZEL_CMDS,
        **kwargs):
    """Macro that defines a test runner that executes a set of Bazel commands against a workspace.

    Args:
        name: The name for the integration runner instance.
        bazel_cmds: A `list` of `string` values that represent arguments for
                    Bazel.
        **kwargs: attributes that are passed to the `sh_binary` target.
    """

    # Prepare the Bazel commands
    args = []
    for cmd in bazel_cmds:
        args.extend(["--bazel_cmd", cmd])

    # Define the shell binary
    binary_name = name + "_binary"
    native.sh_binary(
        name = binary_name,
        srcs = [
            "@bazel_contrib_rules_bazel_integration_test//bazel_integration_test/private:default_test_runner.sh",
        ],
        deps = [
            "@bazel_tools//tools/bash/runfiles",
            "@cgrindel_bazel_starlib//shlib/lib:messages",
        ],
        args = args,
        **kwargs
    )

    # Wrap the arguments with the binary.
    execute_binary(
        name = name,
        binary = binary_name,
        arguments = args,
    )
