// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StopApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "StopApp", targets: ["StopApp"])
    ],
    targets: [
        .executableTarget(
            name: "StopApp",
            path: "Sources/StopApp"
        ),
        .testTarget(
            name: "StopAppTests",
            dependencies: ["StopApp"],
            path: "Tests/StopAppTests"
        )
    ]
)
