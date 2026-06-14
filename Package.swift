// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrbitalMotion",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "OrbitalMotion", targets: ["OrbitalMotion"]),
    ],
    targets: [
        .target(
            name: "OrbitalMotion",
            path: "Sources/OrbitalMotion"
        ),
        .testTarget(
            name: "OrbitalMotionTests",
            dependencies: ["OrbitalMotion"],
            path: "Tests/OrbitalMotionTests"
        ),
    ]
)
