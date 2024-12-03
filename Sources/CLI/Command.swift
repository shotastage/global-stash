//
//  Command.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

struct Command {
    let type: CommandType
    let args: [String]
    
    static func parse(_ arguments: [String]) -> Command? {
        guard arguments.count > 1 else {
            return Command(type: .help, args: [])
        }
        
        if let commandType = CommandType.fromString(arguments[1]) {
            let commandArgs = Array(arguments.dropFirst(2))
            return Command(type: commandType, args: commandArgs)
        }
        
        // If no command is specified, treat the first argument as a file path for stashing
        return Command(type: .save, args: [arguments[1]])
    }
}
