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
    static func main() async {
        // Message on pre-release version
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("THIS PROGRAM IS NOW UNDER CONSTRUCTION!")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print()

        print("Global Stasher - Version 0.1.0")
        print()

        // RunLoopの設定
        let runLoopSource = DispatchSource.makeUserDataAddSource(queue: .main)
        runLoopSource.resume()
        
        // CLIRunnerを実行
        await CLIRunner.run()
        
        // RunLoopSourceを停止
        runLoopSource.cancel()
    }
}
