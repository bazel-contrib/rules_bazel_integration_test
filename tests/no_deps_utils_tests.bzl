"""Tests for `no_deps_utils` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

# buildifier: disable=bzl-visibility
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

def _bazel_binary_repo_name_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "build_bazel_bazel_4_2_1",
        no_deps_utils.bazel_binary_repo_name("4.2.1"),
    )
    asserts.equals(
        env,
        "build_bazel_bazel_.bazelversion",
        no_deps_utils.bazel_binary_repo_name("//:.bazelversion"),
    )
    asserts.equals(
        env,
        "build_bazel_bazel_path_to_bazel_version",
        no_deps_utils.bazel_binary_repo_name("//path/to:bazel_version"),
    )

    return unittest.end(env)

bazel_binary_repo_name_test = unittest.make(_bazel_binary_repo_name_test)

def _semantic_version_to_name_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "4_2_1",
        no_deps_utils.semantic_version_to_name("4.2.1"),
    )
    asserts.equals(
        env,
        "5_0_0-pre_20211011_2",
        no_deps_utils.semantic_version_to_name("5.0.0-pre.20211011.2"),
    )

    return unittest.end(env)

semantic_version_to_name_test = unittest.make(_semantic_version_to_name_test)

def _is_version_file_test(ctx):
    env = unittest.begin(ctx)

    asserts.true(env, no_deps_utils.is_version_file("//:.bazelversion"))
    asserts.false(env, no_deps_utils.is_version_file("4.2.1"))

    return unittest.end(env)

is_version_file_test = unittest.make(_is_version_file_test)

def _bazel_binary_label_test(ctx):
    env = unittest.begin(ctx)

    actual = no_deps_utils.bazel_binary_label("rules_chicken")
    expected = "@rules_chicken//:bazel_binary"
    asserts.equals(env, expected, actual)

    return unittest.end(env)

bazel_binary_label_test = unittest.make(_bazel_binary_label_test)

def _bazel_binary_label_from_version_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "@build_bazel_bazel_4_2_1//:bazel_binary",
        no_deps_utils.bazel_binary_label_from_version("4.2.1"),
    )
    asserts.equals(
        env,
        "@build_bazel_bazel_.bazelversion//:bazel_binary",
        no_deps_utils.bazel_binary_label_from_version("//:.bazelversion"),
    )

    return unittest.end(env)

bazel_binary_label_from_version_test = unittest.make(_bazel_binary_label_from_version_test)

def no_deps_utils_test_suite(name = "no_deps_utils_tests"):
    return unittest.suite(
        name,
        bazel_binary_repo_name_test,
        is_version_file_test,
        semantic_version_to_name_test,
        bazel_binary_label_test,
        bazel_binary_label_from_version_test,
    )
