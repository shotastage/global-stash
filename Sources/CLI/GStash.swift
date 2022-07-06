import Foundation


func prepareWorkDir() {
    var isDirExists = ObjCBool(true)

    fileManager.fileExists(atPath: workingDir, isDirectory: &isDirExists)


    guard (isDirExists.boolValue == true) else {
        return
    }

    print("Initializing Global Stash System...")
    
    do {
        try fileManager.createDirectory(atPath: workingDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create and initialize workspace.")
    }
}
