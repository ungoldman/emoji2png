// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "emoji2png",
  platforms: [.macOS(.v13)],
  targets: [
    .target(name: "EmojiToPNGCore"),
    .executableTarget(name: "emoji2png", dependencies: ["EmojiToPNGCore"]),
    .testTarget(name: "EmojiToPNGCoreTests", dependencies: ["EmojiToPNGCore"]),
  ]
)
