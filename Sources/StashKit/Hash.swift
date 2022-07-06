//
//  File.swift
//  
//
//  Created by Shota Shimazu on 2022/07/06.
//

import Foundation
import CommonCrypto


open class FileSecure {
    
    public static func calcChecksum(data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        data.withUnsafeBytes { rawPtr in
            guard let ptr = rawPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            CC_SHA256(ptr, CC_LONG(data.count), &digest)
        }
 
        return digest.map { String(format: "%02x", $0) }.joined(separator: "")
    }
}
