// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StateKit",
            dependencies: ["Debug"]),
        .testTarget(
            name: "StateKitTests",
            dependencies: ["StateKit"]),
    ]
)
