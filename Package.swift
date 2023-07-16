// swift-tools-version: 5.7.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nametag",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Nametag",
            targets: ["Nametag"]
        ),
        .library(
            name: "TransmissionNametag",
            targets: ["TransmissionNametag"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "2.1.0"),

        .package(url: "https://github.com/OperatorFoundation/Antiphony", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Dice", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Keychain", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/ShadowSwift", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Transmission", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionTypes", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Nametag",
            dependencies:
            [
                .product(name: "Crypto", package: "swift-crypto"),
                "Datable",
                "Dice",
                "Gardener",
                "Keychain",
                "Transmission",
            ]
        ),
        .target(
            name: "TransmissionNametag",
            dependencies:
            [
                "Antiphony",
                "KeychainTypes",
                "Nametag",
                "ShadowSwift",
                "Transmission",
                "TransmissionTypes",
            ]
        ),
        .testTarget(
            name: "NametagTests",
            dependencies: ["Nametag"]),
    ],
    swiftLanguageVersions: [.v5]
)
