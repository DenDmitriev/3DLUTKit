// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "3DLUTKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "3DLUTKit",
            targets: ["3DLUTKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "3DLUTKit"),
        .testTarget(
            name: "3DLUTKitTests",
            dependencies: ["3DLUTKit"]
        ),
    ]
)
