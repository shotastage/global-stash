//
//  StashManager.swift
//  gstash
//
//  Created by Shota Shimazu on 2024/12/03.
//

import Foundation

public struct StashEntry {
    public let id: String
    public let originalPath: String
    public let timestamp: Date
    public let checksum: String
}
// Sources/StashKit/StashManager.swift

import Foundation

public class StashManager {
    private let baseDirectory: String
    private let fileManager: FileManager
    private let dataManager: DataManager
    private let keychain: KeychainManager
    private let secretKey: String
    
    public init(baseDirectory: String) throws {
        self.baseDirectory = baseDirectory
        self.fileManager = FileManager.default
        self.dataManager = DataManager()
        self.keychain = KeychainManager()
        
        // キーチェーンからキーを取得、なければ新規生成
        do {
            self.secretKey = try keychain.loadKey()
        } catch {
            let newKey = try FileCrypt.generateSecretKey(32)  // AES-256用に32バイト
            try keychain.saveKey(newKey)
            self.secretKey = newKey
        }
    }
    
    /// スタッシュファイルを保存する
    /// - Parameter filePath: 保存するファイルのパス
    /// - Returns: 保存されたスタッシュのエントリ情報
    public func save(_ filePath: String) throws -> StashEntry {
        // ファイルの存在確認
        guard fileManager.fileExists(atPath: filePath) else {
            throw StashError.fileNotFound
        }
        
        // スタッシュの保存先ディレクトリを作成
        let stashesDir = "\(baseDirectory)/stashes"
        try fileManager.createDirectory(atPath: stashesDir,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
        
        // スタッシュIDを生成（タイムスタンプベース）
        let timestamp = Date()
        let id = generateStashId(timestamp: timestamp)
        
        // ファイルを読み込み
        guard let fileData = dataManager.readDataFromFile(filePath) else {
            throw StashError.readError
        }
        
        // チェックサムを計算
        let checksum = dataManager.calcChecksum(data: fileData)
        
        // データを暗号化してスタッシュファイルとして保存
        let encryptedData = try FileCrypt.encrypt(fileData, with: secretKey)
        let stashPath = "\(stashesDir)/\(id)"
        try encryptedData.write(to: URL(fileURLWithPath: stashPath))
        
        // メタデータを保存
        let entry = StashEntry(
            id: id,
            originalPath: filePath,
            timestamp: timestamp,
            checksum: checksum
        )
        try saveMetadata(entry)
        
        return entry
    }
    
    /// スタッシュされたファイルの一覧を取得
    /// - Returns: StashEntryの配列
    public func list() throws -> [StashEntry] {
        let metadataDir = "\(baseDirectory)/metadata"
        
        // メタデータディレクトリが存在しない場合は空配列を返す
        guard fileManager.fileExists(atPath: metadataDir) else {
            return []
        }
        
        let metadataFiles = try fileManager.contentsOfDirectory(atPath: metadataDir)
            .filter { $0.hasSuffix(".json") }
        
        // すべてのメタデータを読み込む
        var entries: [StashEntry] = []
        
        for file in metadataFiles {
            let filePath = "\(metadataDir)/\(file)"
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            
            // JSONデコード
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let json = json,
               let id = json["id"] as? String,
               let originalPath = json["originalPath"] as? String,
               let timestamp = json["timestamp"] as? TimeInterval,
               let checksum = json["checksum"] as? String {
                
                let entry = StashEntry(
                    id: id,
                    originalPath: originalPath,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    checksum: checksum
                )
                entries.append(entry)
            }
        }
        
        // タイムスタンプの降順でソート（新しい順）
        return entries.sorted(by: { $0.timestamp > $1.timestamp })
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
