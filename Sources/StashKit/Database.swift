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
    var key: Connection

    public init?() {
        do {
            db = try Connection("\(workingDir)/\(dbFile)")
            key = try Connection("\(workingDir)/\(keys)")
        } catch {
            return nil
        }
        
        prepareTable()
    }

    private func prepareTable() {
        let users = Table("stashed_files")
        do {
            try db.run(users.create { t in
                t.column(Expression<Int64>("id"), primaryKey: true)
                t.column(Expression<String>("fname"))
                t.column(Expression<String>("fhash"))
                t.column(Expression<String>("fbinary"))
                t.column(Expression<String>("fmeta"))
                t.column(Expression<String>("fpermission"))
            })
        } catch {}
    }
}
