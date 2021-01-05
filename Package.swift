// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassLibrarySUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PassLibrarySUI",
            targets: ["PassLibrarySUI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PassLibrarySUI",
            dependencies: []),
        .testTarget(
            name: "PassLibrarySUITests",
            dependencies: ["PassLibrarySUI"]),
    ]
)
