// swift-tools-version:5.3

import PackageDescription

let SExpr = Package(
  name: "SExpr",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "sexpr", targets: ["SExpr"]),
  ],
  targets: [
    .target(name: "SExpr"),
  ]
)
