"""Tests for integration_test_utils."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bazel_integration_test:defs.bzl", "integration_test_utils")

def _semantic_version_to_name_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "4_2_1",
        integration_test_utils.semantic_version_to_name("4.2.1"),
    )
    asserts.equals(
        env,
        "5_0_0-pre_20211011_2",
        integration_test_utils.semantic_version_to_name("5.0.0-pre.20211011.2"),
    )

    return unittest.end(env)

semantic_version_to_name_test = unittest.make(_semantic_version_to_name_test)

def _is_version_file_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

is_version_file_test = unittest.make(_is_version_file_test)

def _bazel_binary_repo_name_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

bazel_binary_repo_name_test = unittest.make(_bazel_binary_repo_name_test)

def _bazel_binary_label_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "@build_bazel_bazel_4_2_1//:bazel_binary",
        integration_test_utils.bazel_binary_label("4.2.1"),
    )

    return unittest.end(env)

bazel_binary_label_test = unittest.make(_bazel_binary_label_test)

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
        semantic_version_to_name_test,
        is_version_file_test,
        bazel_binary_repo_name_test,
        bazel_binary_label_test,
        bazel_integration_test_name_test,
        bazel_integration_test_names_test,
    )
