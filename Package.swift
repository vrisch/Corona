// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Corona",
    products: [
        .library(
            name: "Corona",
            targets: ["Corona"]),
        ],
    dependencies: [
        .package(url: "https://github.com/vrisch/Orbit.git", .branch("develop")),
        ],
    targets: [
        .target(
            name: "Corona",
            dependencies: ["Orbit"]),
        ]
)
