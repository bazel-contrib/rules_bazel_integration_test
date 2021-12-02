protocol CommandRunner {
    func run(command: String, arguments: [String], at path: String) throws -> String
}
