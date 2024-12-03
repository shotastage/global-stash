//
//  CLIRunner.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation
import StashKit

@MainActor
class CLIRunner {
    static let workingDir = "\(NSHomeDirectory())/.gstash"
    
    static func prepareEnvironment() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: workingDir,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        } catch {
            print("Error: Failed to initialize working directory")
            exit(1)
        }
    }
    
    static func run() async {
        prepareEnvironment()
        guard let command = Command.parse(CommandLine.arguments) else {
            showUsage()
            exit(1)
        }
        
        switch command.type {
        case .save:
            await handleSave(args: command.args)
        case .list:
            await handleList()
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
    
    @MainActor
    private static func handleSave(args: [String]) async {
        guard let filePath = args.first else {
            print("Error: No file specified")
            exit(1)
        }
        
        // 絶対パスに変換
        let absolutePath: String
        if filePath.hasPrefix("/") {
            absolutePath = filePath
        } else {
            absolutePath = FileManager.default.currentDirectoryPath + "/" + filePath
        }
        
        let stashManager = StashManager(baseDirectory: workingDir)
        
        do {
            let entry = try await stashManager.save(absolutePath)
            print("Successfully stashed file:")
            print("  ID: \(entry.id)")
            print("  Original path: \(entry.originalPath)")
            print("  Checksum: \(entry.checksum)")
        } catch StashError.fileNotFound {
            print("Error: File not found - \(filePath)")
            exit(1)
        } catch {
            print("Error: Failed to stash file - \(error.localizedDescription)")
            exit(1)
        }
    }
    
    @MainActor
    private static func handleList() async {
        let stashManager = StashManager(baseDirectory: workingDir)
        
        do {
            let entries = try await stashManager.list()
            
            if entries.isEmpty {
                print("No stashed files found.")
                return
            }
            
            // ヘッダーを表示
            print("Stashed files:")
            print(String(repeating: "-", count: 80))
            print(String(format: "%-12s  %-19s  %-35s  %s", "STASH ID", "DATE", "ORIGINAL PATH", "CHECKSUM"))
            print(String(repeating: "-", count: 80))
            
            // エントリを表示
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for entry in entries {
                let date = dateFormatter.string(from: entry.timestamp)
                let checksumPrefix = String(entry.checksum.prefix(8)) // チェックサムの最初の8文字のみ表示
                
                print(String(format: "%-12s  %-19s  %-35s  %s",
                    entry.id,
                    date,
                    entry.originalPath,
                    checksumPrefix
                ))
            }
            print(String(repeating: "-", count: 80))
            
        } catch {
            print("Error: Failed to list stashed files - \(error.localizedDescription)")
            exit(1)
        }
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
