// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gstash",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "gstash", targets: ["CLI"]),
        .library(
            name: "StashKit",
            targets: ["StashKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "CLI",
            dependencies: [
                .target(name: "StashKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        .target(
            name: "StashKit",
            dependencies: [
            ],
            path: "Sources/StashKit"
        ),
        .testTarget(
            name: "gstashTests",
            dependencies: ["CLI"]
        ),
        .testTarget(
            name: "StashKitTests",
            dependencies: ["StashKit"]),
    ],
    swiftLanguageModes: [.v6]
)
