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
        ),
        .executable(
            name: "gitbrain-github-demo",
            targets: ["GitBrainGitHubDemo"]
        ),
        .executable(
            name: "test-github-issue",
            targets: ["TestGitHubIssue"]
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
        .executableTarget(
            name: "GitBrainGitHubDemo",
            dependencies: ["GitBrainSwift"],
            path: "Sources/GitBrainGitHubDemo"
        ),
        .executableTarget(
            name: "TestGitHubIssue",
            dependencies: ["GitBrainSwift"],
            path: "Sources/TestGitHubIssue"
        ),
        .testTarget(
            name: "GitBrainSwiftTests",
            dependencies: ["GitBrainSwift"],
            path: "Tests/GitBrainSwiftTests"
        )
    ]
)
