//
//  File.swift
//  
//
//  Created by Shota Shimazu on 2022/07/08.
//

import XCTest
@testable import StashKit


final class CryptTests: XCTestCase {
    func testGenerateSecretKeyProducesUniqueKeys() throws {
        var keys = Set<String>()

        for _ in 0..<100 {
            let key = try FileCrypt.generateSecretKey(32)
            XCTAssertEqual(key.count, 32)
            XCTAssertTrue(key.contains(where: { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0) }))
            XCTAssertTrue(key.contains(where: { "0123456789".contains($0) }))
            XCTAssertTrue(key.contains(where: { "~!@#$%^&*()-+_}]{[?/>.<,".contains($0) }))
            keys.insert(key)
        }

        XCTAssertEqual(keys.count, 100)
    }

    func testEncryptDecryptRoundTrip() throws {
        let key = try FileCrypt.generateSecretKey(32)
        let original = Data("swift-6.3".utf8)

        let encrypted = try FileCrypt.encrypt(original, with: key)
        let decrypted = try FileCrypt.decrypt(encrypted, with: key)

        XCTAssertEqual(decrypted, original)
    }
}
