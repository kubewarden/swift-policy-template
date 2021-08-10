// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-policy-template",
    dependencies: [
      .package(name: "wapc", url: "https://github.com/flavio/wapc-guest-swift.git", from: "0.0.2"),
      .package(name: "kubewardenSdk", url: "https://github.com/kubewarden/policy-sdk-swift.git", from: "0.1.6"),
      .package(name: "SwiftPath", url: "https://github.com/g-mark/SwiftPath.git", from: "0.3.1"),
      .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
    ],
    targets: [
       .target(
            name: "BusinessLogic",
            dependencies: [
              .product(name: "Logging", package: "swift-log"),
              "kubewardenSdk",
              "SwiftPath",
            ]
        ),
        .target(
            name: "Policy",
            dependencies: ["wapc", "BusinessLogic"],
            linkerSettings: [
                .unsafeFlags(
                    [
                        "-Xlinker",
                        "--export=__guest_call",
                    ]
                )
            ]
        ),
        .testTarget(
            name: "BusinessLogicTests",
            dependencies: ["BusinessLogic"],
            resources: [.process("Examples")]),
    ]
)
