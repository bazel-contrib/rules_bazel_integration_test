load("@cgrindel_swift_bazel//swiftpkg:defs.bzl", "swift_package")

def swift_dependencies():
    # version: 2.3.0
    swift_package(
        name = "swiftpkg_shellout",
        commit = "e1577acf2b6e90086d01a6d5e2b8efdaae033568",
        dependencies_index = "@//:swift_deps_index.json",
        remote = "https://github.com/JohnSundell/ShellOut.git",
    )

    # version: 1.2.2
    swift_package(
        name = "swiftpkg_swift_argument_parser",
        commit = "fee6933f37fde9a5e12a1e4aeaa93fe60116ff2a",
        dependencies_index = "@//:swift_deps_index.json",
        remote = "https://github.com/apple/swift-argument-parser",
    )

def _swift_dependencies_ext_impl(module_ctx):
    swift_dependencies()

swift_dependencies_ext = module_extension(
    implementation = _swift_dependencies_ext_impl,
)
