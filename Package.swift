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
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.7.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.6.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", exact: "6.2.0"),
        .package(url: "https://github.com/mustachedk/RxViewController.git", exact: "2.0.1"),
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
            dependencies: ["MustacheFoundation", "Kingfisher", "SnapKit"]),
        .target(
            name: "MustacheRxSwift",
            dependencies: ["RxSwift", "RxSwiftExt", "RxViewController", "MustacheServices", "MustacheUIKit"]),
        .target(
            name: "MustacheCombine",
            dependencies: ["MustacheFoundation", "Resolver"]),
        .testTarget(
            name: "MustacheCombineTest",
            dependencies: ["MustacheCombine"]),
    ]
)
