//
//  KeychainManager.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation
import Security
import LocalAuthentication

public class KeychainManager {
    private let service = "com.gstash.encryption"
    private let account = "gstash-key"
    
    public func saveKey(_ key: String) throws {
        try deleteKey()
        
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    public func loadKey() async throws -> String {
        try await authenticateWithTouchID()
        return try retrieveKeyFromKeychain()
    }
    
    private func authenticateWithTouchID() async throws {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw KeychainError.biometryNotAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "認証が必要です") { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: KeychainError.authenticationFailed(error))
                } else {
                    continuation.resume(throwing: KeychainError.unknown)
                }
            }
        }
    }
    
    private func retrieveKeyFromKeychain() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.loadFailed(status: status)
        }
        
        return key
    }
    
    private func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

public enum KeychainError: Error {
    case encodingFailed
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case biometryNotAvailable
    case authenticationFailed(Error)
    case unknown
    
    var description: String {
        switch self {
        case .encodingFailed:
            return "Failed to encode key data"
        case .saveFailed(let status):
            return "Failed to save key to Keychain: \(status)"
        case .loadFailed(let status):
            return "Failed to load key from Keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete key from Keychain: \(status)"
        case .biometryNotAvailable:
            return "Touch ID/Face ID is not available on this device"
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
