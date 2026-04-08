//
//  CLIRunner.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation
import StashKit

enum CLIRunner {
    private static let workingDirectory = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        .appendingPathComponent(".gstash", isDirectory: true)
    private static let listColumnWidths = [15, 19, 35, 8]
    private static let listSeparator = String(
        repeating: "-",
        count: listColumnWidths.reduce(0, +) + ((listColumnWidths.count - 1) * 2)
    )
    
    static func prepareEnvironment() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(
                at: workingDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Error: Failed to initialize working directory")
            exit(1)
        }
    }
    
    static func handleSave(filePath: String) async {
        prepareEnvironment()
        let stashManager = StashManager(baseDirectory: workingDirectory.path)
        
        do {
            let entry = try await stashManager.save(resolvedPath(for: filePath))
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

    static func handleList() async {
        prepareEnvironment()
        let stashManager = StashManager(baseDirectory: workingDirectory.path)
        
        do {
            let entries = try await stashManager.list()
            
            if entries.isEmpty {
                print("No stashed files found.")
                return
            }
            
            print("Stashed files:")
            print(listSeparator)
            print(tableRow(["STASH ID", "DATE", "ORIGINAL PATH", "CHECKSUM"]))
            print(listSeparator)

            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for entry in entries {
                print(
                    tableRow([
                        entry.id,
                        dateFormatter.string(from: entry.timestamp),
                        entry.originalPath,
                        String(entry.checksum.prefix(8))
                    ])
                )
            }
            print(listSeparator)
        } catch {
            print("Error: Failed to list stashed files - \(error.localizedDescription)")
            exit(1)
        }
    }
    
    static func handleApply(stashId: String) {
        prepareEnvironment()
        // TODO: Implement apply logic
        print("Applying stash: \(stashId)")
    }
    
    static func handleDrop(stashId: String) {
        prepareEnvironment()
        // TODO: Implement drop logic
        print("Dropping stash: \(stashId)")
    }
    
    static func handleClear() {
        prepareEnvironment()
        // TODO: Implement clear logic
        print("Clearing all stashes...")
    }

    private static func resolvedPath(for filePath: String) -> String {
        if filePath.hasPrefix("/") {
            return URL(fileURLWithPath: filePath).standardizedFileURL.path
        }

        let currentDirectoryURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )

        return currentDirectoryURL.appendingPathComponent(filePath).standardizedFileURL.path
    }

    private static func tableRow(_ columns: [String]) -> String {
        zip(columns, listColumnWidths)
            .map { padded($0.0, to: $0.1) }
            .joined(separator: "  ")
    }

    private static func padded(_ value: String, to width: Int) -> String {
        guard width > 0 else {
            return ""
        }

        if value.count > width {
            if width <= 3 {
                return String(value.prefix(width))
            }

            return String(value.prefix(width - 3)) + "..."
        }

        return value.padding(toLength: width, withPad: " ", startingAt: 0)
    }
}
