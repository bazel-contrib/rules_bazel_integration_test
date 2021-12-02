import ShellOut

struct Bash: CommandRunner {
    func run(command: String, arguments: [String] = [], at path: String = ".") throws -> String {
        return try shellOut(to: command, arguments: arguments, at: path)
    }
}
