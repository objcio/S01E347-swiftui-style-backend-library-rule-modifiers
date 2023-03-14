// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Backend",
            targets: ["Backend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/FlyingFox.git", .upToNextMajor(from: "0.10.0"))

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Backend",
            dependencies: []),
        .executableTarget(
            name: "BackendFF",
            dependencies: [
                "Backend",
                .product(name: "FlyingFox", package: "FlyingFox"),
            ]),
        .testTarget(
            name: "BackendTests",
            dependencies: ["Backend"]),
    ]
)
