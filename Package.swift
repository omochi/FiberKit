// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FiberKit",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "FiberKit",
            targets: ["FiberKit"]),
    ],
    targets: [
        .target(
            name: "FiberKit",
            dependencies: []),
        .testTarget(
            name: "FiberKitTests",
            dependencies: ["FiberKit"]),
    ]
)
