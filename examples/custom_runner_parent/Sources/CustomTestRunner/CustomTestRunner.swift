import ArgumentParser

public struct CustomTestRunner: ParsableCommand {
    enum CustomTestRunnerError: Error {
        case configuredToFail
    }

    @Option(help: "The Bazel executable.")
    var bazel: String

    @Option(help: "The WORKSPACE file.")
    var workspace: String

    var commandRunner: CommandRunner = Bash()

    // The runner needs to be Decodable.
    enum CodingKeys: String, CodingKey {
        case bazel
        case workspace
    }

    public init() {}

    public init(bazel: String, workspace: String) {
        self.bazel = bazel
        self.workspace = workspace
    }

    public func run() throws {
        // This is where the custom test runner would implement its test-specific logic.
        // If the runner needs to report a failure, it should output a useful message to stderr and
        // terminate with a non-zero exit code.
        //
        // This test runner executes `bazel info` and `bazel test //...`.

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
