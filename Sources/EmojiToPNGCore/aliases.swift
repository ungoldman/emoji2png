import Foundation

/// The vendored gemoji shortcode table (see Aliases.generated.swift).
public let emojiAliases: [String: String] =
  try! JSONDecoder().decode([String: String].self, from: Data(aliasesJSON.utf8))

public struct Resolution: Equatable {
  public let emoji: String
  public let aliasName: String?
}

func stripColons(_ s: String) -> String {
  if s.count >= 2, s.hasPrefix(":"), s.hasSuffix(":") {
    return String(s.dropFirst().dropLast())
  }
  return s
}

/// Resolve CLI input to a literal emoji.
/// - a known (de-coloned) alias maps to its emoji, carrying the alias name
/// - otherwise, input containing any emoji scalar passes through unchanged
/// - otherwise, nil (unknown)
public func resolveEmoji(_ input: String,
                         aliases: [String: String] = emojiAliases) -> Resolution? {
  let name = stripColons(input)
  if let emoji = aliases[name] {
    return Resolution(emoji: emoji, aliasName: name)
  }
  if input.unicodeScalars.contains(where: { $0.properties.isEmoji }) {
    return Resolution(emoji: input, aliasName: nil)
  }
  return nil
}
