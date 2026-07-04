import Testing
@testable import EmojiToPNGCore

private let table = ["rocket": "🚀", "rock": "🪨"]

@Test func resolvesBareAlias() {
  #expect(resolveEmoji("rocket", aliases: table)
    == Resolution(emoji: "🚀", aliasName: "rocket"))
}

@Test func resolvesColonAlias() {
  #expect(resolveEmoji(":rocket:", aliases: table)
    == Resolution(emoji: "🚀", aliasName: "rocket"))
}

@Test func passesThroughLiteralEmoji() {
  #expect(resolveEmoji("🚀", aliases: table)
    == Resolution(emoji: "🚀", aliasName: nil))
}

@Test func returnsNilForUnknown() {
  #expect(resolveEmoji("nope", aliases: table) == nil)
}

@Test func stripColonsHandlesBareAndWrapped() {
  #expect(stripColons("rocket") == "rocket")
  #expect(stripColons(":rocket:") == "rocket")
}

@Test func realTableHasCommonAliases() {
  #expect(emojiAliases["rocket"] == "🚀")
  #expect(resolveEmoji(":rocket:")?.emoji == "🚀")
}
