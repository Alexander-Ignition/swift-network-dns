// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-network-dns",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "NetworkDNS",
            targets: ["NetworkDNS"]),
        .executable(
            name: "dns-resolve",
            targets: ["dns-resolve"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkDNS"),
        .testTarget(
            name: "NetworkDNSTests",
            dependencies: ["NetworkDNS"]),
        .executableTarget(
            name: "dns-resolve",
            dependencies: ["NetworkDNS"]),
    ]
)
