workspace(name = "cgrindel_rules_bazel_integration_test")

load("//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# MARK: - Documentation

load("@cgrindel_bazel_doc//bazeldoc:deps.bzl", "bazeldoc_dependencies")

bazeldoc_dependencies()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# MARK: - Update Source

load(
    "@cgrindel_rules_updatesrc//updatesrc:deps.bzl",
    "updatesrc_rules_dependencies",
)

updatesrc_rules_dependencies()

# MARK: - rules_bzlformat

load("@cgrindel_rules_bzlformat//bzlformat:deps.bzl", "bzlformat_rules_dependencies")

bzlformat_rules_dependencies()

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.2")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# MARK: - Integration Tests

load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load("@build_bazel_integration_testing//tools:repositories.bzl", "bazel_binaries")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
