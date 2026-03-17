// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MustacheKit",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
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
        .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),
    ],
    targets: [
        .target(
            name: "MustacheFoundation",
            dependencies: []),
        .target(
            name: "MustacheServices",
            dependencies: [
                "MustacheFoundation",
                .product(name: "Factory", package: "Factory"),
            ]),
        .target(
            name: "MustacheUIKit",
            dependencies: [
                "MustacheFoundation"                
            ],
            resources: [
                .copy("Resources/README.md")
            ]
        ),
        .target(
            name: "MustacheRxSwift",
            dependencies: [
                "RxSwift",
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .target(name: "MustacheServices"),
                .target(name: "MustacheUIKit"),
                .product(name: "Factory", package: "Factory"),
            ]),
        .target(
            name: "MustacheCombine",
            dependencies: [
                "MustacheFoundation",
                "MustacheServices",
                .product(name: "Factory", package: "Factory"),
            ]),
        .testTarget(
            name: "MustacheCombineTest",
            dependencies: ["MustacheCombine"]),
    ]
)
//https://github.com/ReactiveX/RxSwift/releases/download/6.6.0/RxSwift.xcframework.zip
