// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "voting-booth",
  platforms: [
    .macOS(.v10_13),
  ],
  dependencies: [
    .package(url: "https://github.com/Unicus-International/voting-booth-VoteKit", from: "0.0.0"),
    .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
  ],
  targets: [
    .target(name: "VotingBooth", dependencies: ["VoteKit", "PerfectHTTPServer"]),
    .target(name: "voting-booth", dependencies: ["VotingBooth"]),
    .testTarget(name: "VotingBoothTests", dependencies: ["VotingBooth"]),
  ]
)
