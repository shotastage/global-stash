//
//  Crypt.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation
import Security

/// A utility class for cryptographic operations
final class FileCrypt {
    
    /// Character sets used for key generation
    private enum CharacterSet {
        static let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        static let numbers = "0123456789"
        static let symbols = "~!@#$%^&*()-+_}]{[?/>.<,"
        
        static var all: String {
            return letters + numbers + symbols
        }
    }
    
    /// Generates a cryptographically secure random key of specified length
    /// - Parameters:
    ///   - length: The desired length of the key
    ///   - requiresAllCharTypes: If true, ensures the key contains at least one character from each character set
    /// - Returns: A randomly generated key string
    /// - Throws: CryptError if key generation fails
    func generateSecretKey(_ length: Int, requiresAllCharTypes: Bool = true) throws -> String {
        guard length > 0 else {
            throw CryptError.invalidKeyLength
        }
        
        if requiresAllCharTypes && length < 3 {
            throw CryptError.insufficientKeyLength
        }
        
        var randomString = ""
        let allCharacters = CharacterSet.all
        
        // Use SecRandomCopyBytes for cryptographically secure random number generation
        var uint32 = UInt32(0)
        
        // Generate the main part of the key
        for _ in 0..<length {
            guard SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt32>.size, &uint32) == errSecSuccess else {
                throw CryptError.randomGenerationFailed
            }
            
            let index = Int(uint32 % UInt32(allCharacters.count))
            let character = allCharacters[allCharacters.index(allCharacters.startIndex, offsetBy: index)]
            randomString.append(character)
        }
        
        // Ensure all character types are present if required
        if requiresAllCharTypes {
            randomString = try enforceAllCharacterTypes(in: randomString)
        }
        
        return randomString
    }
    
    /// Ensures the generated key contains at least one character from each character set
    /// - Parameter key: The original generated key
    /// - Returns: Modified key containing all character types
    /// - Throws: CryptError if modification fails
    private func enforceAllCharacterTypes(in key: String) throws -> String {
        var modifiedKey = key
        let characterSets = [
            CharacterSet.letters,
            CharacterSet.numbers,
            CharacterSet.symbols
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
}

/// Error types for cryptographic operations
enum CryptError: Error {
    case invalidKeyLength
    case insufficientKeyLength
    case randomGenerationFailed
    case characterSetEmpty
    
    var description: String {
        switch self {
        case .invalidKeyLength:
            return "Key length must be greater than 0"
        case .insufficientKeyLength:
            return "Key length must be at least 3 when requiring all character types"
        case .randomGenerationFailed:
            return "Failed to generate secure random numbers"
        case .characterSetEmpty:
            return "Character set is empty"
        }
    }
}
