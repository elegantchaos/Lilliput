// swift-tools-version:5.3

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "Lilliput",
    platforms: [
        .macOS(.v10_15), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)
    ],
    products: [
        .executable(
            name: "lilli",
            targets: ["lilli"]
        ),
        .library(
            name: "Lilliput",
            targets: ["Lilliput"]
        ),
        .library(
            name: "LilliputExamples",
            targets: ["LilliputExamples"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Coercion.git", from: "1.1.2"),
        .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.4"),
        .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.0"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.6.0"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "lilli",
            dependencies: ["Lilliput", "LilliputExamples"]
        ),
        
        .target(
            name: "Lilliput",
            dependencies: ["Coercion", "CollectionExtensions", "Files", "Logger"]
        ),
        
        .target(
            name: "LilliputExamples",
            dependencies: [],
            resources: [
                .copy("Resources/Games"),
                .copy("Resources/Commands"),
            ]
        ),
        
        .testTarget(
            name: "LilliputTests",
            dependencies: ["Lilliput", "LilliputExamples", "XCTestExtensions"]
        ),
        
    ]
)
