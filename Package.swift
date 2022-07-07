// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "UIComponent",
    platforms: [
        .iOS("11.0")
//        .iOS("13.0")
    ],
    products: [
        .library(
            name: "UIComponent",
            targets: ["UIComponent"]
        )
    ],
    dependencies: [
        .package(url: "http://github.com/NeverAgain11/BaseToolbox", .revisionItem("1940b9170cece7926abbe811ec0590e14f0f99f6"))
//        .package(url: "https://github.com/lkzhao/BaseToolbox", from: "0.1.10")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UIComponent",
            dependencies: ["BaseToolbox"]
        ),
        .testTarget(
            name: "UIComponentTests",
            dependencies: ["UIComponent"]
        ),
    ]
)
