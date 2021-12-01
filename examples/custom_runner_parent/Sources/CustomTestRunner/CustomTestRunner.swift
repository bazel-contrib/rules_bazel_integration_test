import ArgumentParser

struct CustomTestRunner: ParsableCommand {
    @Option(help: "The Bazel executable.")
    var bazel: String

    @Option(help: "The WORKSPACE file.")
    var workspace: String

    func run() {
        Swift.print("MADE IT!")
    }
}
