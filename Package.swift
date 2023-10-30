// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "StateKit",
            targets: ["StateKit"]
        ),
    ],
    dependencies: [
        .package(
            name: "DevKit",
            url: "https://github.com/BergerBytes/devkit.git",
            "1.6.3" ..< "1.7.0"
        ),
        .package(url: "https://github.com/Quick/Quick.git", from: "5.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "StateKit",
            dependencies: ["DevKit"]
        ),
        .testTarget(
            name: "StateKitTests",
            dependencies: ["StateKit", "Quick", "Nimble"]
        ),
    ]
)
