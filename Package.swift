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
        .library(name: "Y86_64SeqLib", targets: ["Y86_64SeqLib"]),
        .executable(name: "Simulator", targets: ["Simulator"]),
        .library(name: "SimulatorLib", targets: ["SimulatorLib"])
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
            dependencies: ["SimulatorLib"]),
        .target(
            name: "Y86_64",
            dependencies: ["Y86_64SeqLib"]),
        
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["SimulatorLib", "Nimble"]),
        .testTarget(
            name: "Y86_64SeqTests",
            dependencies: ["SimulatorLib", "Y86_64SeqLib", "Nimble"]),
    ]
)
