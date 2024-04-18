// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MustacheKit",
    platforms: [.iOS(.v13), .macOS(.v10_14)],
    products: [
        .library(
            name: "MustacheFoundation",
            targets: ["MustacheFoundation"]),
        .library(
            name: "MustacheServices",
            targets: ["MustacheServices"]),
        .library(
            name: "MustacheUIKit",
            targets: ["MustacheUIKit"]),
        .library(
            name: "MustacheRxSwift",
            targets: ["MustacheRxSwift"]),
        .library(
            name: "MustacheCombine",
            targets: ["MustacheCombine"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", "6.6.0"..."6.6.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", "7.11.0"..."7.11.0")
    ],
    targets: [
        .target(
            name: "MustacheFoundation",
            dependencies: []),
        .target(
            name: "MustacheServices",
            dependencies: ["MustacheFoundation"]),
        .target(
            name: "MustacheUIKit",
            dependencies: [
                "MustacheFoundation",
                .product(name: "Kingfisher", package: "Kingfisher")                
            ],
            resources: [
                .copy("Resources/README.md"),
                .process("Resources/Assets.xcassets"),
            ]
        ),
        .target(
            name: "MustacheRxSwift",
            dependencies: [
                "RxSwift",
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .target(name: "MustacheServices"),
                .target(name: "MustacheUIKit")
            ]),
        .target(
            name: "MustacheCombine",
            dependencies: ["MustacheFoundation", "MustacheServices"]),
        .testTarget(
            name: "MustacheCombineTest",
            dependencies: ["MustacheCombine"]),
    ]
)
//https://github.com/ReactiveX/RxSwift/releases/download/6.6.0/RxSwift.xcframework.zip
