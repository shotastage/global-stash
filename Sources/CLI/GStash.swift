import Foundation
import StashKit


// Initialize Command
//
func toolInitialize() {
    prepareWorkDir()

    guard StashDatabase() != nil else {
        print("Failed to initialize database unit due to unkown issue.")
        exit(1)
    }
}

func prepareWorkDir() {

    guard (FileManager.default.fileExists(atPath: workingDir) == false) else {
        return
    }

    print("Initialize Global Stash System (GSS)...")
    
    do {
        try fileManager.createDirectory(atPath: workingDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create and initialize workspace.")
    }
}


// Stash Command
func stash(fname: String) {
    print("Stashing function is now under construction.")
}


// Initialize Command
func resetAll() {
    let ans = yesNo(message: "Are you sure to delete and reset all stashed data & configuration?")
    
    if ans {
        do {
            try FileManager.default.removeItem(atPath: workingDir)
        } catch {
            print("Failed to reset all data!")
            exit(1)
        }
    } else {
        print("Canceled to reset.")
    }
}
