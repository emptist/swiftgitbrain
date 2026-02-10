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
        ),
        .executable(
            name: "gitbrain",
            targets: ["GitBrainCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GitBrainSwift",
            dependencies: [],
            path: "Sources/GitBrainSwift"
        ),
        .executableTarget(
            name: "GitBrainCLI",
            dependencies: ["GitBrainSwift"],
            path: "Sources/GitBrainCLI"
        ),
        .testTarget(
            name: "GitBrainSwiftTests",
            dependencies: ["GitBrainSwift"],
            path: "Tests/GitBrainSwiftTests"
        )
    ]
)
