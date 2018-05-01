// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-test-reporter",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
      .target(
            name: "xc-test-reporter",
            dependencies: ["Lib"]),
      .target(
        name: "Lib",
        dependencies: [
          "Utility",
        ]),
      .testTarget(
        name: "LibTests",
        dependencies: ["Lib"],
        path: "Tests/LibTests"),
    ]
)
