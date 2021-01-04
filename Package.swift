// swift-tools-version:5.3

import PackageDescription

let SExpr = Package(
  name: "SExpr",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "libsexpr", targets: ["SExpr"]),
    .executable(name: "sexpr", targets: ["REPL"]),
  ],
  targets: [
    .target(name: "SExpr"),
    .target(name: "REPL", dependencies: ["SExpr"]),
    .testTarget(name: "SExprTests", dependencies: ["SExpr"]),
  ]
)
