// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GitBrainSwift",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "GitBrainSwift",
            targets: ["GitBrainSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GitBrainSwift",
            dependencies: [],
            path: "Sources/GitBrainSwift"
        ),
        .testTarget(
            name: "GitBrainSwiftTests",
            dependencies: ["GitBrainSwift"],
            path: "Tests/GitBrainSwiftTests"
        )
    ]
)
