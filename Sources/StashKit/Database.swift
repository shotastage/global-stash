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


class StashDatabase {
    let db = try Connection("\(workingDir)/\(dbFile)")

    func initialize() {
        
    
    }
}
