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
            url: "https://github.com/tenmax/tenmax-beacon-library-sdk-ios/releases/download/v1.1.0/TenMaxBeaconSDK.xcframework.zip",
            checksum: "8d8eec872f20bf72d2f01acf33c1841f12100c99db5fb12fbc1ce30ae9a365e9"
        )
    ]
)
