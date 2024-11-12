// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kea",
    products: [
        .executable(name: "kea", targets: ["CLI"]),
        .library(name: "Kea", targets: ["Kea"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "CLI",
            dependencies: [
                .byName(name: "Kea"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ],
            path: "Sources",
            sources: ["CLI.swift"]),
        .target(
            name: "Kea",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
            ],
            path: "Sources",
            exclude: ["CLI.swift"]),
        .testTarget(
            name: "FormatterTests",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .byName(name: "Kea"),
            ]),
    ]
)
