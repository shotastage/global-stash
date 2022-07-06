//
//  CLILib.swift
//  
//
//  Created by Shota Shimazu on 2022/07/06.
//

import Foundation


public func readInput() -> String {
    let input = FileHandle.standardInput.availableData
    return NSString(data: input, encoding: String.Encoding.utf8.rawValue)! as String
}
