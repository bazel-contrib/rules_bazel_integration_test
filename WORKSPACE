workspace(name = "bazel_contrib_rules_bazel_integration_test")

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

load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load("//bazel_integration_test:defs.bzl", "bazel_binaries")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
