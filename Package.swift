// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hapticx",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Hapticx",
            targets: ["Hapticx"])
    ],
    dependencies: [
        // No external dependencies - pure Core Haptics implementation
    ],
    targets: [
        .target(
            name: "Hapticx",
            dependencies: [],
            path: "Sources/Hapticx"
        ),
        .testTarget(
            name: "HapticxTests",
            dependencies: ["Hapticx"],
            path: "Tests"
        )
    ]
)
