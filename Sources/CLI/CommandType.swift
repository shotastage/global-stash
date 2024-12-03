//
//  CommandType.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

enum CommandType: String {
    case save      // stash the file
    case list      // list stashed files
    case apply     // apply stash
    case drop      // remove specific stash
    case clear     // remove all stashes
    case help      // show help message
    
    static func fromString(_ str: String) -> CommandType? {
        switch str.lowercased() {
        case "save", "s": return .save
        case "list", "ls", "l": return .list
        case "apply", "a": return .apply
        case "drop", "d": return .drop
        case "clear": return .clear
        case "help", "h", "--help", "-h": return .help
        default: return nil
        }
    }
}
