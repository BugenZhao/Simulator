// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Simulator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "Y86_64", targets: ["Y86_64"]),
        .library(name: "Y86_64GenericLib", targets: ["Y86_64GenericLib"]),
        .library(name: "Y86_64SeqLib", targets: ["Y86_64SeqLib"]),
        .library(name: "Y86_64PipeLib", targets: ["Y86_64PipeLib"]),
        .executable(name: "Simulator", targets: ["Simulator"]),
        .library(name: "SimulatorLib", targets: ["SimulatorLib"]),
        .library(name: "Yis", targets: ["CYis", "YisWrapper"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.7")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SimulatorLib",
            dependencies: []),
        .target(
            name: "Simulator",
            dependencies: ["SimulatorLib"]),
        .target(
            name: "Y86_64SeqLib",
            dependencies: ["SimulatorLib", "Y86_64GenericLib"]),
        .target(
            name: "Y86_64PipeLib",
            dependencies: ["SimulatorLib", "Y86_64GenericLib"]),
        .target(
            name: "Y86_64GenericLib",
            dependencies: ["SimulatorLib"]),
        .target(
            name: "Y86_64",
            dependencies: ["Y86_64SeqLib"]),
        .target(
            name: "YisWrapper",
            dependencies: ["CYis", "Y86_64GenericLib"]),
        .target(
            name: "CYis",
            dependencies: []),
        
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["SimulatorLib", "Nimble"]),
        .testTarget(
            name: "Y86_64SeqTests",
            dependencies: ["SimulatorLib", "Y86_64SeqLib", "Nimble", "YisWrapper"]),
        .testTarget(
            name: "Y86_64PipeTests",
            dependencies: ["SimulatorLib", "Y86_64PipeLib", "Nimble", "YisWrapper"]),
    ]
)
