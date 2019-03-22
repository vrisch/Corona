// swift-tools-version:5.0
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
            name: "Corona"),
        ]
)
