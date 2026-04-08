//
//  GlobalStash.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//
@main
enum GStash {
    static func main() async {
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
