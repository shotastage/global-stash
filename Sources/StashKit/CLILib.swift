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
    while true {
        print("\(message) [Y/N] ", terminator: "")
        if let ans = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
            switch ans.lowercased() {
            case "yes", "y":
                return true
            case "no", "n":
                return false
            default:
                print("Please enter 'Y' for yes or 'N' for no.")
            }
        }
    }
}
