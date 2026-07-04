import Testing
@testable import EmojiToPNGCore

@Test func parsesInputOnly() throws {
  let o = try parseArguments(["emoji2png", "rocket"])
  #expect(o == Options(input: "rocket", output: nil, size: 160))
}

@Test func parsesInputAndOutput() throws {
  let o = try parseArguments(["emoji2png", "rocket", "out.png"])
  #expect(o == Options(input: "rocket", output: "out.png", size: 160))
}

@Test func parsesSizeFlag() throws {
  let o = try parseArguments(["emoji2png", "rocket", "--size", "256"])
  #expect(o.size == 256)
}

@Test func sizeFlagBeforePositionals() throws {
  let o = try parseArguments(["emoji2png", "--size", "64", "rocket"])
  #expect(o == Options(input: "rocket", output: nil, size: 64))
}

@Test func missingInputThrows() {
  #expect(throws: ArgError.missingInput) { _ = try parseArguments(["emoji2png"]) }
}

@Test func nonIntegerSizeThrows() {
  #expect(throws: ArgError.badSize("big")) {
    _ = try parseArguments(["emoji2png", "x", "--size", "big"])
  }
}

@Test func zeroSizeThrows() {
  #expect(throws: ArgError.badSize("0")) {
    _ = try parseArguments(["emoji2png", "x", "--size", "0"])
  }
}

@Test func sizeFlagWithoutValueThrows() {
  #expect(throws: ArgError.badSize("")) {
    _ = try parseArguments(["emoji2png", "x", "--size"])
  }
}

@Test func unknownFlagThrows() {
  #expect(throws: ArgError.unknownFlag("--bogus")) {
    _ = try parseArguments(["emoji2png", "--bogus"])
  }
}

@Test func singleDashFlagThrows() {
  #expect(throws: ArgError.unknownFlag("-x")) {
    _ = try parseArguments(["emoji2png", "-x"])
  }
}

@Test func helpThrows() {
  #expect(throws: ArgError.help) { _ = try parseArguments(["emoji2png", "-h"]) }
  #expect(throws: ArgError.help) { _ = try parseArguments(["emoji2png", "--help"]) }
}

@Test func outputNameExplicitWins() {
  #expect(outputName(explicit: "a.png", aliasName: "rocket") == "a.png")
}

@Test func outputNameFromAlias() {
  #expect(outputName(explicit: nil, aliasName: "rocket") == "rocket.png")
}

@Test func outputNameFallback() {
  #expect(outputName(explicit: nil, aliasName: nil) == "emoji.png")
}
