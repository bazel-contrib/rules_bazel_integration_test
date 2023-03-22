workspace(name = "rules_bazel_integration_test")

load("//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# MARK: - Documentation

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# MARK: - Buildifier Deps

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Integration Tests

# TODO(chuck): Clean me up

# load(
#     "//:bazel_versions.bzl",
#     # "CURRENT_BAZEL_VERSION",
#     # "OTHER_BAZEL_VERSIONS",
#     "SUPPORTED_BAZEL_VERSIONS",
# )
# load("//bazel_integration_test/bzlmod:workspace_bazel_binaries.bzl", "workspace_bazel_binaries")

# # This is only necessary while rules_bazel_integration_test switches back and
# # forth between WORKSPACE repositories and bzlmod repositories.
# workspace_bazel_binaries(
#     name = "bazel_binaries",
#     current_version = CURRENT_BAZEL_VERSION,
#     other_versions = OTHER_BAZEL_VERSIONS,
#     rbt_repo_name = "",
# )

load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load("//bazel_integration_test:repo_defs.bzl", "bazel_binaries")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
