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
    try! fileManager.createDirectory(atPath: "\(homeDir)/.gstash", withIntermediateDirectories: true, attributes: nil)
}


func main() {
    prepareWorkDir()

    guard CommandLine.arguments.count == 2 else {
        print("usage: lc [absolute path of a file]")
        exit(1)
    }

    let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
    guard let file = try? String(contentsOf: fileUrl, encoding: .utf8) else {
        print("Error: could not read \(fileUrl.absoluteString)")
        exit(2)
    }

    print(file.components(separatedBy: CharacterSet.newlines).count)
}
