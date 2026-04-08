import XCTest
import Foundation

final class gstashTests: XCTestCase {
  func testHelpOutputIncludesUsage() throws {
        #if !targetEnvironment(macCatalyst)

    let gstashBinary = productsDirectory.appendingPathComponent("gstash")

        let process = Process()
    process.executableURL = gstashBinary
    process.arguments = ["help"]

        let pipe = Pipe()
        process.standardOutput = pipe
    process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(process.terminationStatus, 0)
    XCTAssertTrue(output?.contains("gstash - Global Stash Tool") == true)
    XCTAssertTrue(output?.contains("Usage:") == true)
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
