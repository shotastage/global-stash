//
//  StashManager.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation
import LocalAuthentication

public class StashManager {
    private let baseDirectory: String
    private let fileManager: FileManager
    private let dataManager: DataManager
    private let keychain: KeychainManager
    private var secretKey: String?
    
    public init(baseDirectory: String) {
        self.baseDirectory = baseDirectory
        self.fileManager = FileManager.default
        self.dataManager = DataManager()
        self.keychain = KeychainManager()
    }
    
    private func ensureAuthenticated() async throws {
        if secretKey == nil {
            self.secretKey = try await keychain.loadKey()
        }
    }
    
    public func list() async throws -> [StashEntry] {
        try await ensureAuthenticated()
        
        let metadataDir = "\(baseDirectory)/metadata"
        guard fileManager.fileExists(atPath: metadataDir) else {
            return []
        }
        
        let metadataFiles = try fileManager.contentsOfDirectory(atPath: metadataDir)
            .filter { $0.hasSuffix(".json") }
        
        return try metadataFiles.compactMap { file -> StashEntry? in
            let filePath = "\(metadataDir)/\(file)"
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["id"] as? String,
                  let originalPath = json["originalPath"] as? String,
                  let timestamp = json["timestamp"] as? TimeInterval,
                  let checksum = json["checksum"] as? String else {
                return nil
            }
            
            return StashEntry(
                id: id,
                originalPath: originalPath,
                timestamp: Date(timeIntervalSince1970: timestamp),
                checksum: checksum
            )
        }.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    public func save(_ filePath: String) async throws -> StashEntry {
        try await ensureAuthenticated()
        guard let key = secretKey else {
            throw StashError.authenticationRequired
        }
        
        guard fileManager.fileExists(atPath: filePath) else {
            throw StashError.fileNotFound
        }
        
        let stashesDir = "\(baseDirectory)/stashes"
        try fileManager.createDirectory(atPath: stashesDir,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
        
        let timestamp = Date()
        let id = generateStashId(timestamp: timestamp)
        
        guard let fileData = dataManager.readDataFromFile(filePath) else {
            throw StashError.readError
        }
        
        let checksum = dataManager.calcChecksum(data: fileData)
        let encryptedData = try FileCrypt.encrypt(fileData, with: key)
        let stashPath = "\(stashesDir)/\(id)"
        try encryptedData.write(to: URL(fileURLWithPath: stashPath))
        
        let entry = StashEntry(
            id: id,
            originalPath: filePath,
            timestamp: timestamp,
            checksum: checksum
        )
        try saveMetadata(entry)
        
        return entry
    }
    
    private func generateStashId(timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: timestamp)
    }
    
    private func saveMetadata(_ entry: StashEntry) throws {
        let metadataDir = "\(baseDirectory)/metadata"
        try fileManager.createDirectory(atPath: metadataDir,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
        
        let metadata: [String: Any] = [
            "id": entry.id,
            "originalPath": entry.originalPath,
            "timestamp": entry.timestamp.timeIntervalSince1970,
            "checksum": entry.checksum
        ]
        
        let metadataPath = "\(metadataDir)/\(entry.id).json"
        let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
        try jsonData.write(to: URL(fileURLWithPath: metadataPath))
    }
}

public enum StashError: Error {
    case fileNotFound
    case readError
    case writeError
    case metadataError
    case authenticationRequired
    
    public var description: String {
        switch self {
        case .fileNotFound:
            return "Specified file not found"
        case .readError:
            return "Failed to read file"
        case .writeError:
            return "Failed to write stash"
        case .metadataError:
            return "Failed to save metadata"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
