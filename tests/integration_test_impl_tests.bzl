"""Tests for private implementation functions."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

# buildifier: disable=bzl-visibility
load("//bazel_integration_test/private:bazel_binaries.bzl", "get_version_from_file")

def _parse_bazelversion_file_test(ctx):
    env = unittest.begin(ctx)

    def mock_repository_ctx(*, version_file, version_path, version_content):
        def path(_):
            return version_path

        def read(_):
            return version_content

        return struct(
            attr = struct(version_file = version_file),
            path = path,
            read = read,
        )

    simple_ctx = mock_repository_ctx(
        version_file = "//:.bazelversion",
        version_path = "/workspace/.bazelversion",
        version_content = "6.0.0",
    )
    asserts.equals(env, "6.0.0", get_version_from_file(simple_ctx), "Parses file containing only the version.")

    whitespace_ctx = mock_repository_ctx(
        version_file = "//:.bazelversion",
        version_path = "/workspace/.bazelversion",
        version_content = " \n6.0.0\n \n",
    )
    asserts.equals(env, "6.0.0", get_version_from_file(whitespace_ctx), "Parses file with surrounding whitespace.")

    trailing_lines_ctx = mock_repository_ctx(
        version_file = "//:.bazelversion",
        version_path = "/workspace/.bazelversion",
        version_content = "6.0.0\na trailing line\n# and another line\n",
    )
    asserts.equals(env, "6.0.0", get_version_from_file(trailing_lines_ctx), "Parses file with trainling lines.")

    return unittest.end(env)

parse_bazelversion_file_test = unittest.make(_parse_bazelversion_file_test)

def integration_test_impl_test_suite():
    return unittest.suite(
        "integration_test_impl_tests",
        parse_bazelversion_file_test,
    )
