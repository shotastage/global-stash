//
//  File.swift
//  
//
//  Created by Shota Shimazu on 2022/07/08.
//

import XCTest
@testable import StashKit


final class CryptTests: XCTestCase {
    func testSha256Sum() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        

        let crypt = FileCrypt()
        
        for _ in 0...100 {
            XCTAssertNotEqual(crypt.genSecretkey(256), crypt.genSecretkey(256))
        }
    }
}
