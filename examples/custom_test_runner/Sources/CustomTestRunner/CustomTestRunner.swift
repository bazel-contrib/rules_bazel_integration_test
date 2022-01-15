import ArgumentParser
import Foundation

public struct CustomTestRunner: ParsableCommand {
    enum CustomTestRunnerError: Error {
        case configuredToFail
        case missingEnvVariable(String)
    }

    var commandRunner: CommandRunner = Bash()

    // The runner needs to be Decodable.
    enum CodingKeys: CodingKey {}

    public init() {}

    public func run() throws {
        // This is where the custom test runner would implement its test-specific logic.
        // If the runner needs to report a failure, it should output a useful message to stderr and
        // terminate with a non-zero exit code.
        //
        // This test runner executes `bazel info` and `bazel test //...`.

        guard let bazel = ProcessInfo.processInfo.environment["BIT_BAZEL_BINARY"] else {
            throw CustomTestRunnerError.missingEnvVariable("BIT_BAZEL_BINARY")
        }
        guard let workspace = ProcessInfo.processInfo.environment["BIT_WORKSPACE_DIR"] else {
            throw CustomTestRunnerError.missingEnvVariable("BIT_WORKSPACE_DIR")
        }

        Swift.print("bazel: \(String(reflecting: bazel))")
        Swift.print("workspace: \(String(reflecting: workspace))")

        let infoOutput = try commandRunner.run(command: bazel, arguments: ["info"], at: workspace)
        print("Bazel Info:")
        print(infoOutput)

        let testOutput = try commandRunner.run(
            command: bazel, arguments: ["test", "//..."], at: workspace
        )
        print("Test Output:")
        print(testOutput)
    }
}
