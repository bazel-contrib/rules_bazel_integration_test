"""Defines the default test runner for integration tests."""

load(
    "@cgrindel_bazel_starlib//shlib/rules:execute_binary.bzl",
    "execute_binary_utils",
)
load(":integration_test_utils.bzl", "integration_test_utils")

def _default_test_runner_impl(ctx):
    if len(ctx.attr.args) > 0:
        fail("""\
The args attribute is not supported. Use the bazel_cmds instead.\
""")

    test_runner_args = []
    for cmd in ctx.attr.bazel_cmds:
        test_runner_args.extend(["--bazel_cmd", cmd])

    out = ctx.actions.declare_file(ctx.label.name + ".sh")
    execute_binary_utils.write_execute_binary_script(
        write_file = ctx.actions.write,
        out = out,
        bin_path = ctx.executable._test_runner_script.short_path,
        arguments = test_runner_args,
        workspace_name = ctx.workspace_name,
    )

    runfiles = ctx.runfiles(files = ctx.files._test_runner_script)
    runfiles = execute_binary_utils.collect_runfiles(
        runfiles,
        [ctx.attr._test_runner_script],
    )

    return DefaultInfo(executable = out, runfiles = runfiles)

default_test_runner = rule(
    implementation = _default_test_runner_impl,
    attrs = {
        "bazel_cmds": attr.string_list(
            default = integration_test_utils.DEFAULT_BAZEL_CMDS,
            doc = """\
The Bazel commands to be executed by the test runner in the test workspace.\
""",
        ),
        "_test_runner_script": attr.label(
            default = "//bazel_integration_test/private:default_test_runner.sh",
            executable = True,
            allow_files = True,
            cfg = "target",
        ),
    },
    doc = "",
    executable = True,
)

# load("@cgrindel_bazel_starlib//shlib/rules:execute_binary.bzl", "execute_binary")
# load(":integration_test_utils.bzl", "integration_test_utils")

# def default_test_runner(
#         name,
#         bazel_cmds = integration_test_utils.DEFAULT_BAZEL_CMDS,
#         **kwargs):
#     """Macro that defines a test runner that executes a set of Bazel commands against a workspace.

#     Args:
#         name: The name for the integration runner instance.
#         bazel_cmds: A `list` of `string` values that represent arguments for
#                     Bazel.
#         **kwargs: attributes that are passed to the `sh_binary` target.
#     """

#     # Prepare the Bazel commands
#     args = []
#     for cmd in bazel_cmds:
#         args.extend(["--bazel_cmd", cmd])

#     # Define the shell binary
#     binary_name = name + "_binary"
#     native.sh_binary(
#         name = binary_name,
#         srcs = [
#             "@rules_bazel_integration_test//bazel_integration_test/private:default_test_runner.sh",
#         ],
#         args = args,
#         **kwargs
#     )

#     # Wrap the arguments with the binary.
#     execute_binary(
#         name = name,
#         binary = binary_name,
#         arguments = args,
#     )
