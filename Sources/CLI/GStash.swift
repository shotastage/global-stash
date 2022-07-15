import Foundation
import StashKit


// Initialize Command
//
func prepareEnvironment() {
    guard (FileManager.default.fileExists(atPath: workingDir) == false) else {
        return
    }

    Logger.message("Initialize Global Stash System (GSS)...")
    
    do {
        try fileManager.createDirectory(atPath: workingDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        Logger.message("Failed to create and initialize workspace.")
    }

    guard StashDatabase() != nil else {
        Logger.message("Failed to initialize database unit due to unkown issue.")
        exit(1)
    }

    do {
        try StashDatabase()?.prepareSchema()
    } catch {
        Logger.log("Table is already exist?")
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
