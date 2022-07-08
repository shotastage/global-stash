//
//  StashStore.swift
//  
//
//  Created by Shota Shimazu on 2022/07/07.
//

import Foundation


open class StashStore {

    var targetData: Data? = nil
    var fileName: String = ""
    var permission: Int = 0

    let manager = DataManager()
    let db = StashDatabase()

    public init(_ path: String) {
        fileName = path
    }

    public func dataLoaded() {
        targetData = manager.readDataFromFile(fileName)
    }

    /// Validate if the read data can be stashed
    /// - Returns: Validation result
    public func validate() -> Bool {
        let data = (targetData != nil)
        let file = (fileName != "")
        let permission = (self.permission != 0)

        return (data && file && permission)
    }

    
    /// Proceed and store stashing file data
    public func store() {
        dataLoaded()

        if !validate() {
            print("Failed to stash file!")
            exit(1)
        }

        try! db?.insertStashes(
            id: "",
            file: fileName,
            checksum: manager.calcChecksum(data: targetData!),
            binary: "",
            meta: "",
            permission: 100)

    }
}
