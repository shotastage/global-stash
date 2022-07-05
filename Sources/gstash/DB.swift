//
//  DB.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation
import GRDB


let dbFile = "stash.db"
let keys = "keys.db"


class StashDatabase {

    let dbQueue = try DatabaseQueue(path: "\(workingDir)/\(dbFile)")

    func initialize() {
        try dbQueue.write { db in
            try db.create(table: "stash_contents") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("hash", .text).notNull()
                t.column("value", .text).notNull()
            }
        }
    }

    func initialize22() {
        try dbQueue.write { db in
            try db.create(table: "stash_contents") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("hash", .text).notNull()
                t.column("value", .text).notNull()
            }
        }
    }
}
