//
//  DB.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation


let dbFile = "stash.db"
let keys = "keys.db"

let workingDir = "\(NSHomeDirectory())/.gstash"

let fileManager = FileManager.default


open class StashDatabase {


    public init?() {

        do {
            Logger.log("LOAD DATABASE \(workingDir)/\(dbFile)")
            Logger.log("LOAD DATABASE \(workingDir)/\(keys)")

            
        } catch {
            Logger.log("FAILED TO ESTABLISH CONNECTIONS!")
            return nil
        }
    }
}
