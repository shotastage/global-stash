//
//  File.swift
//  
//
//  Created by Shota Shimazu on 2022/07/07.
//

import Foundation


open class FileDataFlow {

    var targetData: Data? = nil
    var fileName: String = ""
    var permission: Int = 0

    let manager = FileDataManager()

    public init(_ path: String) {
        fileName = path
    }

    public func dataLoaded() {
        targetData = manager.readDataFromFile(fileName)
    }

    public func validate() -> Bool {
        let data = (targetData != nil)
        let file = (fileName != "")
        let permission = (self.permission != 0)

        return (data && file && permission)
    }
}
