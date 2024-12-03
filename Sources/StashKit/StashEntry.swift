//
//  StashEntry.swift
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
