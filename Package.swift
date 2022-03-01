// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "StateKit",
            targets: ["StateKit"]),
    ],
    dependencies: [
        .package(
            name: "Debug",
            url: "https://github.com/BergerBytes/swift-debug.git",
            "1.4.0"..<"1.5.0"
        ),
    ],
    targets: [
        .target(
            name: "StateKit",
            dependencies: ["Debug"]
        ),
        .testTarget(
            name: "StateKitTests",
            dependencies: ["StateKit"]),
    ]
)
