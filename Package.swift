// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MustacheKit",
    platforms: [.iOS(.v12), .macOS(.v10_14)],
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
            targets: ["MustacheCombine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", exact: "1.5.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.6.0"),
    ],
    targets: [
        .target(
            name: "MustacheFoundation",
            dependencies: []),
        .target(
            name: "MustacheServices",
            dependencies: ["MustacheFoundation", "Resolver"]),
        .target(
            name: "MustacheUIKit",
            dependencies: ["MustacheFoundation"]),
        .target(
            name: "MustacheRxSwift",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift"), "MustacheServices", "MustacheUIKit"]),
        .target(
            name: "MustacheCombine",
            dependencies: ["MustacheFoundation"]),
        .testTarget(
            name: "MustacheCombineTest",
            dependencies: ["MustacheCombine"]),
    ]
)
