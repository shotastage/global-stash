import Foundation


let homeDir = NSHomeDirectory()

let fileManager = FileManager.default

func prepareWorkDir() {
    var isDirExists = ObjCBool(true)

    fileManager.fileExists(atPath: "\(homeDir)/.gstash", isDirectory: &isDirExists)

    print(homeDir)

    guard (isDirExists.boolValue == true) else {
        return
    }

    print("Initializing Global Stash System...")
    
    do {
        try fileManager.createDirectory(atPath: "\(homeDir)/.gstash", withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create and initialize workspace.")
    }
}
