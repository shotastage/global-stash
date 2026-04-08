//
//  StashManager.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation

public actor StashManager {
    private let baseDirectoryURL: URL
    private let fileManager: FileManager
    private let dataManager: DataManager
    private let keychain: KeychainManager
    private var secretKey: String?
    
    public init(baseDirectory: String) {
        self.baseDirectoryURL = URL(fileURLWithPath: baseDirectory, isDirectory: true)
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
        
        let metadataDirectoryURL = baseDirectoryURL.appendingPathComponent("metadata", isDirectory: true)
        guard fileManager.fileExists(atPath: metadataDirectoryURL.path) else {
            return []
        }
        
        let metadataFiles = try fileManager.contentsOfDirectory(
            at: metadataDirectoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "json" }

        return try metadataFiles
            .map(decodeMetadata)
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    public func save(_ filePath: String) async throws -> StashEntry {
        try await ensureAuthenticated()
        guard let key = secretKey else {
            throw StashError.authenticationRequired
        }

        let sourceURL = URL(fileURLWithPath: filePath).standardizedFileURL
        
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw StashError.fileNotFound
        }
        
        let stashesDirectoryURL = baseDirectoryURL.appendingPathComponent("stashes", isDirectory: true)
        try fileManager.createDirectory(
            at: stashesDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let timestamp = Date()
        let id = generateStashID(from: timestamp)
        
        guard let fileData = dataManager.readDataFromFile(sourceURL.path) else {
            throw StashError.readError
        }
        
        let checksum = dataManager.calcChecksum(data: fileData)
        let encryptedData = try FileCrypt.encrypt(fileData, with: key)

        do {
            let stashURL = stashesDirectoryURL.appendingPathComponent(id, isDirectory: false)
            try encryptedData.write(to: stashURL, options: .atomic)
        } catch {
            throw StashError.writeError
        }
        
        let entry = StashEntry(
            id: id,
            originalPath: sourceURL.path,
            timestamp: timestamp,
            checksum: checksum
        )
        try saveMetadata(entry)
        
        return entry
    }
    
    private func decodeMetadata(from fileURL: URL) throws -> StashEntry {
        do {
            let data = try Data(contentsOf: fileURL)
            return try Self.makeMetadataDecoder().decode(StashEntry.self, from: data)
        } catch {
            throw StashError.metadataError
        }
    }

    private func generateStashID(from timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: timestamp)
    }
    
    private func saveMetadata(_ entry: StashEntry) throws {
        let metadataDirectoryURL = baseDirectoryURL.appendingPathComponent("metadata", isDirectory: true)
        try fileManager.createDirectory(
            at: metadataDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        do {
            let metadataURL = metadataDirectoryURL.appendingPathComponent("\(entry.id).json", isDirectory: false)
            let jsonData = try Self.makeMetadataEncoder().encode(entry)
            try jsonData.write(to: metadataURL, options: .atomic)
        } catch {
            throw StashError.metadataError
        }
    }

    private static func makeMetadataDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    private static func makeMetadataEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

public enum StashError: Error, LocalizedError, CustomStringConvertible {
    case fileNotFound
    case readError
    case writeError
    case metadataError
    case authenticationRequired
    
    public var errorDescription: String? {
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

    public var description: String {
        errorDescription ?? "Unknown stash error"
    }
}
