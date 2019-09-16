// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "voting-booth",
  dependencies: [
    .package(url: "https://github.com/Unicus-International/voting-booth-VoteKit", from: "0.0.0"),
  ],
  targets: [
    .target(name: "VotingBooth", dependencies: ["VoteKit"]),
    .target(name: "voting-booth", dependencies: ["VotingBooth"]),
    .testTarget(name: "VotingBoothTests", dependencies: ["VotingBooth"]),
  ]
)
