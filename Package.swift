// swift-tools-version:5.5

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "Lilliput",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
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
        .package(url: "https://github.com/elegantchaos/Coercion.git", from: "1.1.3"),
        .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.9"),
        .package(url: "https://github.com/elegantchaos/DictionaryResolver.git", from: "1.2.2"),
        .package(url: "https://github.com/elegantchaos/Expressions.git", from: "1.1.1"),
        .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.2"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.7.3"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "lilli",
            dependencies: ["Lilliput", "LilliputExamples"]
        ),
        
        .target(
            name: "Lilliput",
            dependencies: [
                "Coercion",
                "CollectionExtensions",
                "DictionaryResolver",
                "Expressions",
                "Files",
                "Logger"
            ],
            resources: [
                .copy("Resources/Types"),
            ]
        ),
        
        .target(
            name: "LilliputExamples",
            dependencies: [],
            resources: [
                .copy("Resources/Games"),
                .copy("Resources/Commands"),
                .copy("Resources/Definitions"),
            ]
        ),
        
        .testTarget(
            name: "LilliputTests",
            dependencies: ["Lilliput", "LilliputExamples", "XCTestExtensions"]
        ),
        
    ]
)
