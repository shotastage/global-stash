//
//  main.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation
import StashKit



let workingDir = "\(NSHomeDirectory())/.gstash"

let fileManager = FileManager.default


Logger.log("THIS PROGRAM IS NOW UNDER CONSTRUCTION!")
toolInitialize()


guard CommandLine.arguments.count == 2 else {
    print("Usage: gstash [Stashing file] or [Command Options]")
    exit(1)
}


let givenArg = CommandLine.arguments[1]

switch givenArg {
case "ls":
    Logger.message("Listing stashed files is now under construction.")
case "export":
    Logger.message("Exporting stashed file is now under construction.")
case "reset-all":
    resetAll()
default:
    stash(givenArg)
}
