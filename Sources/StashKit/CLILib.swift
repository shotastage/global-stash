//
//  CLILib.swift
//  
//
//  Created by Shota Shimazu on 2022/07/06.
//

import Foundation


public func readInput(message: String = "") -> String {

    if message != "" {
        print("\(message) : ", terminator: "")
    }

    return readLine()!
}


public func yesNo(message: String) -> Bool {

    let ans = readInput(message: "\(message) [Y/N]")
    
    switch ans {
    case "Yes", "yes", "Y", "y":
            return true
    case "No", "no", "N", "n":
        return false
    default:
        return false
    }
}
