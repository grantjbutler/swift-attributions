// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-attributions",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
    ],
    products: [
        .plugin(name: "AttributionPlugin", targets: ["AttributionPlugin"]),
        .executable(name: "AttributionGenerator", targets: ["AttributionGenerator"]),
        
        .library(name: "AttributionsSwiftUI", targets: ["AttributionsSwiftUI"]),
        .library(name: "AttributionsUIKit", targets: ["AttributionsUIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(name: "AttributionsCore"),
        .target(name: "AttributionsSwiftUI", dependencies: ["AttributionsCore"]),
        .target(name: "AttributionsUIKit", dependencies: ["AttributionsCore"]),
        
        .executableTarget(name: "AttributionGenerator", dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .plugin(name: "AttributionPlugin", capability: .buildTool(), dependencies: ["AttributionGenerator"])
    ]
)
