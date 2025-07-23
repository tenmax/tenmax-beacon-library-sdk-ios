// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "TenMaxBeaconSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "TenMaxBeaconSDK",
            targets: ["TenMaxBeaconSDK"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "TenMaxBeaconSDK",
            url: "https://github.com/tenmax/tenmax-beacon-library-sdk-ios/releases/download/v1.0.0/TenMaxBeaconSDK.xcframework.zip",
            checksum: "95fdf68e64fcf4c4ec06b4f4730700a2366708244cd222a6ca9f94dbaf5b6c4d"
        )
    ]
)
