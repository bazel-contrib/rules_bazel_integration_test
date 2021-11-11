load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _semantic_version_to_name_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

semantic_version_to_name_test = unittest.make(_semantic_version_to_name_test)

def _bazel_binary_label_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

bazel_binary_label_test = unittest.make(_bazel_binary_label_test)

def _bazel_integration_test_name_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

bazel_integration_test_name_test = unittest.make(_bazel_integration_test_name_test)

def integration_test_utils_test_suite():
    return unittest.suite(
        "integration_test_utils_tests",
        semantic_version_to_name_test,
        bazel_binary_label_test,
        bazel_integration_test_name_test,
    )
