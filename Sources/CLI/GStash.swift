//
//  GStash.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation
import StashKit


// Initialize Command
//
func prepareEnvironment() {
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: "~/.gstash") {
        Logger.message("Global Stasher is already initialized.")
    }
}

// Initialize Command
func resetAll() {
    let ans = yesNo(message: "Are you sure to delete and reset all stashed data & configuration?")
    
    if ans {
        do {
            try FileManager.default.removeItem(atPath: workingDir)
        } catch {
            Logger.message("Failed to reset all data!")
            exit(1)
        }
    } else {
        Logger.message("Canceled to reset.")
    }
}

func stash(_ filePath: String) {
    let stasher = StashStore(filePath)
    
    stasher.store()
}
