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


class StashDatabase {
    let db: Connection?

    init() {
        do {
            db = try Connection("\(workingDir)/\(dbFile)")
        } catch {
            db = nil
        }
    }

    func initialize() {
    
    }
}
