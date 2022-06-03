load(
    "@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_test",
)

load("@cgrindel_bazel_starlib//shlib/rules:execute_binary.bzl", "execute_binary")

load(
    "//:bazel_versions.bzl",
    "CURRENT_BAZEL_VERSION",
)

def custom_bazel_integration_test(
        name,
        test_runner,
        workspace_path,
        **kwargs):

    native.sh_binary(
        name = "%s_wrapper" % name,
        srcs = ["//:test_runner_wrapper.sh"],
        deps = [
            "@bazel_tools//tools/bash/runfiles",
        ],
        data = [
            "@contrib_rules_bazel_integration_test//tools:create_scratch_dir",
        ],
        testonly = True,
    )

    bazel_integration_test(
        name = name,
        bazel_version = CURRENT_BAZEL_VERSION,
        test_runner = "%s_wrapper" % name,
        test_runner_args = ["--test-runner", "$(location %s)" % test_runner],
        workspace_path = workspace_path,
        data = [test_runner],
    )

