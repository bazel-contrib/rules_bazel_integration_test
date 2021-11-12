load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _something_test(ctx):
    env = unittest.begin(ctx)

    asserts.true(env, True)

    return unittest.end(env)

something_test = unittest.make(_something_test)

def mockascript_test_suite():
    return unittest.suite(
        "mockascript_tests",
        something_test,
    )
