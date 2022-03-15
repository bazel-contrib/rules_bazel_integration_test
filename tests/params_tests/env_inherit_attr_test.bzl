"""Macro for asserting the existence of `env_inherit` values."""

def env_inherit_attr_test(name, integration_test, expected_values):
    """Test for the existence of the specified values for a test target's `env_inherit` attribute.

    Args:
        name: The name of the test.
        integration_test: The test target to check.
        expected_values: A `list` of `string` values expected in `env_inherit`.
    """
    query_name = name + "_query"
    native.genquery(
        name = query_name,
        testonly = True,
        expression = integration_test,
        opts = [
            "--output=xml",
            "--xml:default_values",
        ],
        scope = [integration_test],
    )

    native.sh_test(
        name = name,
        srcs = ["env_inherit_attr_test.sh"],
        args = [
            "$(location {query_name})".format(query_name = query_name),
        ] + expected_values,
        data = [query_name],
        deps = [
            "@bazel_tools//tools/bash/runfiles",
            "@cgrindel_bazel_starlib//shlib/lib:assertions",
            "@cgrindel_bazel_starlib//shlib/lib:env",
        ],
    )
