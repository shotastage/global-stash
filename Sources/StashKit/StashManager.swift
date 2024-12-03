//
//  StashManager.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//
// Sources/StashKit/StashManager.swift

import Foundation

public struct StashEntry {
    public let id: String
    public let originalPath: String
    public let timestamp: Date
    public let checksum: String
}

public class StashManager {
    private let baseDirectory: String
    private let fileManager: FileManager
    private let dataManager: DataManager
    private let crypter: FileCrypt
    private let keychain: KeychainManager
    private let secretKey: String  // メモリ上での一時的な保持のみ
    
    public init(baseDirectory: String) throws {
        self.baseDirectory = baseDirectory
        self.fileManager = FileManager.default
        self.dataManager = DataManager()
        self.crypter = FileCrypt()
        self.keychain = KeychainManager()
        
        // キーチェーンからキーを取得、なければ新規生成
        do {
            self.secretKey = try keychain.loadKey()
        } catch {
            let newKey = try crypter.generateSecretKey(32)  // AES-256用に32バイト
            try keychain.saveKey(newKey)
            self.secretKey = newKey
        }
    }
    
    public func save(_ filePath: String) throws -> StashEntry {
        // 1. ファイルの存在確認
        guard fileManager.fileExists(atPath: filePath) else {
            throw StashError.fileNotFound
        }
        
        // 2. スタッシュの保存先ディレクトリを作成
        let stashesDir = "\(baseDirectory)/stashes"
        try fileManager.createDirectory(atPath: stashesDir,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
        
        // 3. スタッシュIDを生成（タイムスタンプベース）
        let timestamp = Date()
        let id = generateStashId(timestamp: timestamp)
        
        // 4. ファイルを読み込み
        guard let fileData = dataManager.readDataFromFile(filePath) else {
            throw StashError.readError
        }
        
        // 5. チェックサムを計算
        let checksum = dataManager.calcChecksum(data: fileData)
        
        // 6. データを暗号化してスタッシュファイルとして保存
        let encryptedData = try crypter.encrypt(fileData, with: secretKey)
        let stashPath = "\(stashesDir)/\(id)"
        try encryptedData.write(to: URL(fileURLWithPath: stashPath))
        
        // 7. メタデータを保存
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
        }
    }
}
