"""Tests for integration_test_utils."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bazel_integration_test:defs.bzl", "integration_test_utils")

def _bazel_integration_test_name_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "foo_bar_bazel_4_2_1",
        integration_test_utils.bazel_integration_test_name("foo_bar", "4.2.1"),
    )

    return unittest.end(env)

bazel_integration_test_name_test = unittest.make(_bazel_integration_test_name_test)

def _bazel_integration_test_names_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        [
            integration_test_utils.bazel_integration_test_name("foo_bar", "4.2.1"),
            integration_test_utils.bazel_integration_test_name("foo_bar", "5.0.0"),
        ],
        integration_test_utils.bazel_integration_test_names("foo_bar", ["4.2.1", "5.0.0"]),
    )

    return unittest.end(env)

bazel_integration_test_names_test = unittest.make(_bazel_integration_test_names_test)

def integration_test_utils_test_suite():
    return unittest.suite(
        "integration_test_utils_tests",
        bazel_integration_test_name_test,
        bazel_integration_test_names_test,
    )
