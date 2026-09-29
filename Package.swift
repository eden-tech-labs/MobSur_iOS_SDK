// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "MobSur_iOS_SDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "MobSur_iOS_SDK",
            targets: ["MobSur_iOS_SDK"]),
    ],
    targets: [
        // Built from https://github.com/eden-tech-labs/MobSur-iOS-Framework with ./build.sh.
        // Minimum iOS version, marketing version and podspec must stay in sync with that project.
        .binaryTarget(
            name: "MobSur_iOS_SDK",
            path: "MobSur_iOS_SDK.xcframework"),
    ]
)
