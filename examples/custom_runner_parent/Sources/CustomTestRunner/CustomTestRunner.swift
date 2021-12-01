import ArgumentParser

// @main
public struct CustomTestRunner: ParsableCommand {
    @Option(help: "The Bazel executable.")
    var bazel: String

    @Option(help: "The WORKSPACE file.")
    var workspace: String

    public init() {}

    public func run() {
        Swift.print("MADE IT!")
    }
}
