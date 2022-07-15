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
    var keyConn: Connection

    public init?() {

        do {
            Logger.log("LOAD DATABASE \(workingDir)/\(dbFile)")
            Logger.log("LOAD DATABASE \(workingDir)/\(keys)")

            db = try Connection("\(workingDir)/\(dbFile)")
            keyConn = try Connection("\(workingDir)/\(keys)")
        } catch {
            Logger.log("FAILED TO ESTABLISH CONNECTIONS!")
            return nil
        }
    }

    let id = Expression<Int64>("id")
    let fid = Expression<String>("fid")
    let fname = Expression<String>("fname")
    let fhash = Expression<String>("fhash")
    let fbin = Expression<String>("fbin")
    let fmeta = Expression<String>("fmeta")
    let fpermission = Expression<Int>("fpermission")


    let keyid = Expression<Int64>("id")
    let keystr = Expression<String>("keystr")


    public func prepare() {
        let files = Table("stashed_files")
        do {
            try db.run(files.create { t in
                t.column(id, primaryKey: true)
                t.column(fid)
                t.column(fname)
                t.column(fhash)
                t.column(fbin)
                t.column(fmeta)
                t.column(fpermission)
            })
        } catch {
            Logger.log("FAILED TO CREATE TABLE stashed_files")
        }

        let keys = Table("keys")
        do {
            try keyConn.run(keys.create { t in
                t.column(keyid, primaryKey: true)
                t.column(keystr)
            })
        } catch {
            Logger.log("FAILED TO CREATE TABLE keys")
        }
    }

    public func insertStashes(id: String, file: String, checksum: String, binary: String, meta: String, permission: Int) throws {
        let table = Table("stashed_files")
        let fid = Expression<String>("fid")
        let fname = Expression<String>("fname")
        let fhash = Expression<String>("fhash")
        let fbinary = Expression<String>("fbinary")
        let fmeta = Expression<String>("fmeta")
        let fpermission = Expression<Int>("fpermission")

        let insert = table.insert(
            fid <- fid,
            fname <- file,
            fhash <- checksum,
            fbinary <- binary,
            fmeta <- meta,
            fpermission <- permission)

        try db.run(insert)
    }

    public func insertKeys(keyid: String, key: String) throws {
        let table = Table("keys")
        let keyid = Expression<String>("keyid")
        let key = Expression<String>("key")

        let insert = table.insert(keyid <- keyid, key <- key)
        try keyConn.run(insert)
    }
}
