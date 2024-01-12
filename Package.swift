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
        .library(
            name: "TransmissionAsyncNametag",
            targets: ["TransmissionAsyncNametag"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "3.2.0"),
        .package(url: "https://github.com/OperatorFoundation/Antiphony", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Datable", from: "4.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Dice", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Keychain", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/ShadowSwift", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Transmission", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionTypes", branch: "release"),
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
                "TransmissionAsync"
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
        .target(
            name: "TransmissionAsyncNametag",
            dependencies:
            [
                "Antiphony",
                "KeychainTypes",
                "Nametag",
                "ShadowSwift",
                "TransmissionAsync",
            ]
        ),
        .testTarget(
            name: "NametagTests",
            dependencies: ["Nametag", "TransmissionNametag", "TransmissionAsyncNametag"]),
    ],
    swiftLanguageVersions: [.v5]
)
