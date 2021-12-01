protocol CommandRunner {
    func run(commandName: String, arguments: [String]) throws -> String
}
