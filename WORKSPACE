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

load("//bazel_integration_test:repo_defs.bzl", "bazel_binaries")

bazel_binaries(versions = [
    "//:.bazelversion",
    "7.0.0-pre.20230823.4",
])

# MARK: - Markdown

# Workaround for missing strict deps error as described here:
# https://github.com/bazelbuild/bazel-gazelle/issues/1217#issuecomment-1152236735
# gazelle:repository go_repository name=in_gopkg_alecthomas_kingpin_v2 importpath=gopkg.in/alecthomas/kingpin.v2

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@cgrindel_bazel_starlib//:go_deps.bzl", "bazel_starlib_go_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

bazel_starlib_go_dependencies()

go_rules_dependencies()

go_register_toolchains(version = "1.19.5")

gazelle_dependencies()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

http_file(
    name = "sample_file",
    sha256 = "0baf36f9c3ef9d8b4833833e1d633707965c9850f69f04dd96712672b9e75cc0",
    url = "https://raw.githubusercontent.com/bazel-contrib/rules_bazel_integration_test/v0.12.0/.bazelversion",
)

http_archive(
    name = "rules_shell",
    sha256 = "410e8ff32e018b9efd2743507e7595c26e2628567c42224411ff533b57d27c28",
    strip_prefix = "rules_shell-0.2.0",
    url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.2.0/rules_shell-v0.2.0.tar.gz",
)

load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")

rules_shell_dependencies()

rules_shell_toolchains()
