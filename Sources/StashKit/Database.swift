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


public enum StashDBTable: String {
    case stash = "stash"
    case key = "key"
}

public struct Stash: Codable, FetchableRecord, PersistableRecord {
    var id: Int64
    var name: String
    var content: String
    var meta: String
    var permission: Int
    var isEncrypted: Bool
}

open class StashDatabase {

    let dbQueue: DatabaseQueue
    let keyQueue: DatabaseQueue

    public init?() {

        do {
            dbQueue = try DatabaseQueue(path: "\(workingDir)/\(dbFile)")
            keyQueue = try DatabaseQueue(path: "\(workingDir)/\(keys)")
        } catch {
            Logger.log("FAILED TO ESTABLISH CONNECTIONS!")
            return nil
        }
    }

    public func prepareSchema() throws {
        try dbQueue.write { db in
            try db.create(table: StashDBTable.stash.rawValue) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("content", .text).notNull()
                t.column("meta", .text).notNull()
                t.column("permission", .integer).notNull()
                t.column("isencrypted", .boolean).notNull()
            }
        }
        
        try keyQueue.write { db in
            try db.create(table: StashDBTable.key.rawValue) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("key_alg", .text).notNull()
                t.column("key", .text).notNull()
            }
        }
    }

    public func insert() {
        
    }
}
