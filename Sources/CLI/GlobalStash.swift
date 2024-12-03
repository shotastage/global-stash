//
//  GlobalStash.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation
import StashKit

@main
struct GStash {
    static func main() async throws {
        // Message on pre-release version
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("THIS PROGRAM IS NOW UNDER CONSTRUCTION!")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print()

        print("Global Stasher - Version 0.1.0")
        print()

        await CLIRunner.run()
    }
}
