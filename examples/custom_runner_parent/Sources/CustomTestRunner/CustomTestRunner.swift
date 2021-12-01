import ArgumentParser

public struct CustomTestRunner: ParsableCommand {
    enum CustomTestRunnerError: Error {
        case configuredToFail
    }

    @Option(help: "The Bazel executable.")
    var bazel: String

    @Option(help: "The WORKSPACE file.")
    var workspace: String

    @Flag(help: "Specifies whether the runner should fail.")
    var fail = false

    public init() {}

    public func run() throws {
        // This is where the custom test runner would implement its test-specific logic.
        // If the runner needs to report a failure, it should output a useful message to stderr and
        // terminate with a non-zero exit code.
        Swift.print("bazel: \(String(reflecting: bazel))")
        Swift.print("workspace: \(String(reflecting: workspace))")
        if fail {
            throw CustomTestRunnerError.configuredToFail
        }
    }
}
