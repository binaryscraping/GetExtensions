// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "GetExtensions",
  platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
  products: [
    .library(name: "GetExtensions", targets: ["GetExtensions"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kean/Get", from: "2.1.4"),
  ],
  targets: [
    .target(name: "GetExtensions", dependencies: ["Get"]),
    .testTarget(name: "GetExtensionsTests", dependencies: ["GetExtensions"]),
  ]
)
