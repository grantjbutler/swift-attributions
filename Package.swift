// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-attributions",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .plugin(name: "AttributionPlugin", targets: ["AttributionPlugin"]),
        .executable(name: "AttributionGenerator", targets: ["AttributionGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(name: "AttributionGenerator", dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .plugin(name: "AttributionPlugin", capability: .buildTool(), dependencies: ["AttributionGenerator"])
    ]
)
