// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Corona",
    products: [
        .library(
            name: "Corona",
            targets: ["Corona"]),
        ],
    targets: [
        .target(
            name: "Corona",
            dependencies: ["Orbit"]),
        ]
)
