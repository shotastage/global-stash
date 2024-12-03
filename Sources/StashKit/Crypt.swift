//
//  Crypt.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//
import Foundation
import Security
import CommonCrypto

public final class FileCrypt {
    // AES暗号化のキーサイズ
    private static let kKeySize = kCCKeySizeAES256
    
    // 文字セット定義
    private static let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private static let numbers = "0123456789"
    private static let symbols = "~!@#$%^&*()-+_}]{[?/>.<,"
    
    private static var allCharacters: String {
        return letters + numbers + symbols
    }
    
    /// 暗号化用のランダムな文字列キーを生成する
    /// - Parameters:
    ///   - length: The desired length of the key
    ///   - requiresAllCharTypes: If true, ensures the key contains at least one character from each character set
    /// - Returns: A randomly generated key string
    /// - Throws: CryptError if key generation fails
    public static func generateSecretKey(_ length: Int = 32, requiresAllCharTypes: Bool = true) throws -> String {
        guard length > 0 else {
            throw CryptError.invalidKeyLength
        }
        
        if requiresAllCharTypes && length < 3 {
            throw CryptError.insufficientKeyLength
        }
        
        var randomString = ""
        
        // Use SecRandomCopyBytes for cryptographically secure random number generation
        var uint32 = UInt32(0)
        
        // Generate the main part of the key
        for _ in 0..<length {
            guard SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt32>.size, &uint32) == errSecSuccess else {
                throw CryptError.randomGenerationFailed
            }
            
            let index = Int(uint32 % UInt32(allCharacters.count))
            let stringIndex = allCharacters.index(allCharacters.startIndex, offsetBy: index)
            randomString.append(allCharacters[stringIndex])
        }
        
        // Ensure all character types are present if required
        if requiresAllCharTypes {
            randomString = try enforceAllCharacterTypes(in: randomString)
        }
        
        return randomString
    }
    
    /// Ensures the generated key contains at least one character from each character set
    private static func enforceAllCharacterTypes(in key: String) throws -> String {
        var modifiedKey = key
        let characterSets = [
            letters,
            numbers,
            symbols
        ]
        
        // Check if any character set is missing
        for charSet in characterSets {
            if !modifiedKey.contains(where: { charSet.contains($0) }) {
                guard let randomChar = charSet.randomElement() else {
                    throw CryptError.characterSetEmpty
                }
                
                // Replace a random character in the key
                let randomIndex = modifiedKey.index(modifiedKey.startIndex, offsetBy: Int.random(in: 0..<modifiedKey.count))
                modifiedKey.remove(at: randomIndex)
                modifiedKey.insert(randomChar, at: randomIndex)
            }
        }
        
        return modifiedKey
    }
    
    /// データの暗号化を行う
    /// - Parameters:
    ///   - data: 暗号化する元データ
    ///   - key: 暗号化キー（32バイト）
    /// - Returns: 暗号化されたデータ
    /// - Throws: CryptError if encryption fails
    public static func encrypt(_ data: Data, with key: String) throws -> Data {
        guard let keyData = key.data(using: .utf8),
              keyData.count == kKeySize else {
            throw CryptError.invalidKeyLength
        }
        
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted = 0
        
        let status = buffer.withUnsafeMutableBytes { bufferPtr in
            data.withUnsafeBytes { dataPtr in
                keyData.withUnsafeBytes { keyPtr in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyPtr.baseAddress,
                        kKeySize,
                        nil,
                        dataPtr.baseAddress,
                        data.count,
                        bufferPtr.baseAddress,
                        bufferSize,
                        &numBytesEncrypted
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw CryptError.encryptionFailed
        }
        
        return buffer.prefix(numBytesEncrypted)
    }
    
    /// データの復号化を行う
    /// - Parameters:
    ///   - data: 復号化する暗号化データ
    ///   - key: 復号化キー（32バイト）
    /// - Returns: 復号化されたデータ
    /// - Throws: CryptError if decryption fails
    public static func decrypt(_ data: Data, with key: String) throws -> Data {
        guard let keyData = key.data(using: .utf8),
              keyData.count == kKeySize else {
            throw CryptError.invalidKeyLength
        }
        
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted = 0
        
        let status = buffer.withUnsafeMutableBytes { bufferPtr in
            data.withUnsafeBytes { dataPtr in
                keyData.withUnsafeBytes { keyPtr in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyPtr.baseAddress,
                        kKeySize,
                        nil,
                        dataPtr.baseAddress,
                        data.count,
                        bufferPtr.baseAddress,
                        bufferSize,
                        &numBytesDecrypted
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw CryptError.decryptionFailed
        }
        
        return buffer.prefix(numBytesDecrypted)
    }
}

public enum CryptError: Error {
    case invalidKeyLength
    case insufficientKeyLength
    case randomGenerationFailed
    case characterSetEmpty
    case encryptionFailed
    case decryptionFailed
    
    public var description: String {
        switch self {
        case .invalidKeyLength:
            return "Key length must be greater than 0"
        case .insufficientKeyLength:
            return "Key length must be at least 3 when requiring all character types"
        case .randomGenerationFailed:
            return "Failed to generate secure random numbers"
        case .characterSetEmpty:
            return "Character set is empty"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        }
    }
}
