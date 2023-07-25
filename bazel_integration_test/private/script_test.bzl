"A facility for script tests that create workspaces and call Bazel."

load(
    "//bazel_integration_test/private:bazel_integration_test.bzl",
    "bazel_integration_test",
)

_RUNNER_SCRIPT = """
#!/bin/bash

script="%s"

working_dir="."
cd "${working_dir}"

export bazel

# Run the actual tests
# Bazel is available as ${BIT_BAZEL_BINARY}.
if "${script}"; then
  echo "test passed"
else
  echo "test failed"
  exit 1
fi

exit 0
"""

def _write_runner_impl(ctx):
    script = ctx.file.script
    runner = ctx.outputs.out

    ctx.actions.write(
        output = runner,
        content = _RUNNER_SCRIPT % script.path,
    )

    return [DefaultInfo(
        executable = runner,
        runfiles = ctx.runfiles(files = ctx.files.script),
    )]

_write_runner = rule(
    implementation = _write_runner_impl,
    attrs = {
        "out": attr.output(mandatory = True),
        "script": attr.label(allow_single_file = True, mandatory = True),
    },
    executable = True,
)

def script_test(
        name,
        srcs,
        deps,
        bazel_binaries,
        bazel_version):
    """
    Macro that allows writing script tests which create a Bazel workspace and call the binary directly.

    These are intended to be like the Bazel integration tests found at https://github.com/bazelbuild/bazel/tree/master/src/test/shell/integration.

    Tests will find the Bazel binary via the `${BIT_BAZEL_BINARY}` environment variable.

    Args:
        name: name of the resulting test
        srcs: The file containing the shell script. This attribute must be a
            singleton list, whose only element is the shell script. This script
            must be executable, and may be a source file or a generated file. All
            other files required at runtime (whether scripts or data) belong in the
            deps attribute.
        deps: The list of library targets to be used in this test.
        bazel_binaries: Optional for WORKSPACE loaded repositories. Required
            for repositories that enable bzlmod. The value for this parameter
            is loaded by adding
            `load("@bazel_binaries//:defs.bzl", "bazel_binaries")` to your
            build file.
        bazel_version: Optional. A `string` value representing the semantic
                       version of Bazel to use for the integration test. If a
                       version is not specified, then the `bazel_binary` must
                       be specified.
    """
    runner_script = "%s_runner.sh" % name
    runner_target = "%s_runner" % name

    if len(srcs) != 1:
        fail("script_test.srcs must be a singleton list, got %s" % srcs)

    src = srcs[0]

    # Generate the test runner script that calls inner.
    _write_runner(
        name = "generate_%s" % runner_target,
        script = src,
        out = runner_script,
        testonly = True,
    )

    # Create the test runner that sets up and calls the test.
    native.sh_binary(
        name = runner_target,
        testonly = True,
        srcs = [runner_script],
        data = [src],
        deps = deps,
        tags = ["manual"],
    )

    # The actual test that is invoked.
    bazel_integration_test(
        name = name,
        bazel_binaries = bazel_binaries,
        bazel_version = bazel_version,
        test_runner = ":%s" % runner_target,
    )
