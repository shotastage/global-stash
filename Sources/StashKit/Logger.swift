//
//  File.swift
//  
//
//  Created by Shota Shimazu on 2022/07/08.
//

import Foundation

open class Logger {


    public static func log(_ msg: String) {
        #if DEBUG
            print("STASHER DEBUG LOG: \(msg)")
        #endif
    }

    public static func message(_ msg: String) {
        let suffix = "Global Stasher: "

        print("\(suffix)\(msg)")
    }
}
