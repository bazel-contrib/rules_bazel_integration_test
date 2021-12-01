import ShellOut

struct Bash: CommandRunner {
    func run(commandName: String, arguments: [String] = []) throws -> String {
        return try shellOut(to: commandName, arguments: arguments)
    }
}

// struct Bash: CommandExecuting {
//     func run(commandName: String, arguments: [String] = []) throws -> String {
//         return try run(resolve(commandName), with: arguments)
//     }

//     private func resolve(_ command: String) throws -> String {
//         guard var bashCommand = try? run("/bin/bash", with: ["-l", "-c", "which \(command)"]) else {
//             throw BashError.commandNotFound(name: command)
//         }
//         bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//         return bashCommand
//     }

//     private func run(_ command: String, with arguments: [String] = []) throws -> String {
//         let process = Process()
//         process.launchPath = command
//         process.arguments = arguments
//         let outputPipe = Pipe()
//         process.standardOutput = outputPipe
//         process.launch()
//         let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//         let output = String(decoding: outputData, as: UTF8.self)
//         return output
//     }
// }
