//
//  CLIRunner.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation

class CLIRunner {
    static func run() {
        guard let command = Command.parse(CommandLine.arguments) else {
            showUsage()
            exit(1)
        }
        
        switch command.type {
        case .save:
            handleSave(args: command.args)
        case .list:
            handleList()
        case .apply:
            handleApply(args: command.args)
        case .drop:
            handleDrop(args: command.args)
        case .clear:
            handleClear()
        case .help:
            showHelp()
        }
    }
    
    private static func showUsage() {
        print("Usage: gstash <command> [arguments]")
        print("Run 'gstash help' for more information.")
    }
    
    private static func showHelp() {
        print("""
        gstash - Global Stash Tool
        
        Usage:
          gstash <command> [arguments]
        
        Commands:
          save, s <file>      Save a file to stash
          list, ls, l         List all stashed files
          apply, a <id>       Apply a stash
          drop, d <id>        Remove a specific stash
          clear               Remove all stashes
          help, h             Show this help message
        
        Examples:
          gstash save myfile.txt         # Stash myfile.txt
          gstash myfile.txt              # Same as above
          gstash list                    # List all stashes
          gstash apply 1                 # Apply stash with ID 1
        """)
    }
    
    private static func handleSave(args: [String]) {
        guard let filePath = args.first else {
            print("Error: No file specified")
            exit(1)
        }
        // TODO: Implement save logic
        print("Saving file: \(filePath)")
    }
    
    private static func handleList() {
        // TODO: Implement list logic
        print("Listing stashed files...")
    }
    
    private static func handleApply(args: [String]) {
        guard let stashId = args.first else {
            print("Error: No stash ID specified")
            exit(1)
        }
        // TODO: Implement apply logic
        print("Applying stash: \(stashId)")
    }
    
    private static func handleDrop(args: [String]) {
        guard let stashId = args.first else {
            print("Error: No stash ID specified")
            exit(1)
        }
        // TODO: Implement drop logic
        print("Dropping stash: \(stashId)")
    }
    
    private static func handleClear() {
        // TODO: Implement clear logic
        print("Clearing all stashes...")
    }
}
