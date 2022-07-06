//
//  DB.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation
import SQLite


let dbFile = "stash.db"
let keys = "keys.db"

let workingDir = "\(NSHomeDirectory())/.gstash"

let fileManager = FileManager.default


open class StashDatabase {
    var db: Connection

    public init?() {
        do {
            db = try Connection("\(workingDir)/\(dbFile)")
        } catch {
            return nil
        }
    }
}
