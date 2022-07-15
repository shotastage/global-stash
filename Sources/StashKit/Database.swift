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

let workingDir = "\(NSHomeDirectory())/.gstash"

let fileManager = FileManager.default


open class StashDatabase {

    let dbQueue: DatabaseQueue
    let keyQueue: DatabaseQueue

    public init?() {

        do {
            Logger.log("LOAD DATABASE \(workingDir)/\(dbFile)")
            Logger.log("LOAD DATABASE \(workingDir)/\(keys)")

            dbQueue = try DatabaseQueue(path: "\(workingDir)/\(dbFile)")
            keyQueue = try DatabaseQueue(path: "\(workingDir)/\(keys)")
        } catch {
            Logger.log("FAILED TO ESTABLISH CONNECTIONS!")
            return nil
        }
    }

    func prepareSchema() throws {
        try dbQueue.write { db in
            try db.create(table: "stashes") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("content", .text).notNull()
                t.column("is_encrypted", .boolean).notNull()

            }
        }
    }
}
