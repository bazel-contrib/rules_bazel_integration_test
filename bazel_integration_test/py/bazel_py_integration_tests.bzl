load("@rules_python//python:defs.bzl", "py_binary")
load("//bazel_integration_test:defs.bzl", "bazel_integration_tests")

def bazel_py_integration_tests(name, srcs, bazel_versions, main = None, deps = []):
    # Declare the test runner
    runner_name = name
    py_binary(
        name = runner_name,
        srcs = srcs,
        main = main,
        testonly = True,
        deps = deps + [
            "//bazel_integration_test/py:test_base",
        ],
    )

    # Declare the integration tests.
    bazel_integration_tests(
        name = name,
        bazel_versions = bazel_versions,
        test_runner = runner_name,
    )
