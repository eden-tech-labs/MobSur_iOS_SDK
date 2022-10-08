// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobSur_iOS_SDK",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MobSur_iOS_SDK",
            targets: ["MobSur-iOS-Framework"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .binaryTarget(
            name: "MobSur-iOS-Framework",
            path: "MobSur-iOS-Framework.xcframework"),
        
//        .target(
//            name: "MobSur_iOS_SDK",
//            dependencies: []),
//        
//        .testTarget(
//            name: "MobSur_iOS_SDKTests",
//            dependencies: ["MobSur_iOS_SDK", "MobSur-iOS-Framework"]),
    ]
)
