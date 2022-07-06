import Foundation


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
