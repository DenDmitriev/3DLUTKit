// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "3DLUTKit",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "3DLUTKit",
            targets: ["3DLUTKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.3.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "3DLUTKit",
            dependencies: ["Kingfisher"],
            resources: [
                .process("Resources/Kodachrome 25.cube"),
                .process("Resources/ColorCheckerPortrait.jpeg"),
                .process("Resources/teal_orange_plus_contrast.png")
            ]
        ),
        .testTarget(
            name: "3DLUTKitTests",
            dependencies: ["3DLUTKit"],
            resources: [
                .process("Resources/fuji_eterna_250d_fuji_3510.png"),
                .process("Resources/Kodachrome 25.cube"),
                .process("Resources/ARRI_LogC4-to-Gamma24_Rec709-D65_v1-65.cube"),
                .process("Resources/Contrast17.cube")
            ]
        ),
    ]
)
