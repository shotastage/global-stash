//
//  GlobalStash.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//
@main
enum GStash {
    static func main() async {
        // Message on pre-release version
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("THIS PROGRAM IS NOW UNDER CONSTRUCTION!")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print()

        print("Global Stasher - Version 0.1.0")
        print()

        await GStashCommand.main(Array(normalizedArguments().dropFirst()))
    }

    private static func normalizedArguments() -> [String] {
        guard CommandLine.arguments.count > 1 else {
            return CommandLine.arguments
        }

        var arguments = CommandLine.arguments
        let firstArgument = arguments[1].lowercased()

        if firstArgument == "h" {
            arguments[1] = "help"
            return arguments
        }

        if firstArgument.hasPrefix("-") || GStashCommand.commandNames.contains(firstArgument) {
            return arguments
        }

        arguments.insert("save", at: 1)
        return arguments
    }
}
