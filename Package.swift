// swift-tools-version: 6.0
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
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        //.package(url: "https://github.com/groue/GRDB.swift.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "CLI",
            dependencies: [
                .target(name: "StashKit")
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
    ]
)
