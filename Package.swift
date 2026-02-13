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
            name: "gitbrain-migrate",
            targets: ["GitBrainMigrationCLI"]
        ),
        .executable(
            name: "brainstate-test",
            targets: ["BrainStateCommunicationTest"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:vapor/fluent.git", from: "4.0.0"),
        .package(url: "git@github.com:vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "GitBrainSwift",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
            ],
            path: "Sources/GitBrainSwift"
        ),
        .executableTarget(
            name: "GitBrainCLI",
            dependencies: ["GitBrainSwift"],
            path: "Sources/GitBrainCLI"
        ),
        .executableTarget(
            name: "GitBrainMigrationCLI",
            dependencies: ["GitBrainSwift", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "Sources/GitBrainMigrationCLI"
        ),
        .testTarget(
            name: "GitBrainSwiftTests",
            dependencies: ["GitBrainSwift"],
            path: "Tests/GitBrainSwiftTests"
        ),
        .executableTarget(
            name: "GitBrainSwiftBenchmarks",
            dependencies: ["GitBrainSwift"],
            path: "Benchmarks"
        ),
        .executableTarget(
            name: "BrainStateCommunicationTest",
            dependencies: ["GitBrainSwift"],
            path: "Sources/BrainStateCommunicationTest"
        )
    ]
)
