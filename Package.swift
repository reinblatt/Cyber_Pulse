// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CyberPulse",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "CyberPulse",
            targets: ["CyberPulse"])
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2")
    ],
    targets: [
        .executableTarget(
            name: "CyberPulse",
            dependencies: ["FeedKit"],
            path: "CyberPulse",
            resources: [
                .process("Resources")
            ]
        )
    ]
) 