public struct Options: Equatable {
  public let input: String
  public let output: String?
  public let size: Int
}

public enum ArgError: Error, Equatable {
  case help
  case missingInput
  case badSize(String)
  case unknownFlag(String)
}

/// Parse `argv` (program name at index 0) into `Options`.
public func parseArguments(_ argv: [String]) throws -> Options {
  var positionals: [String] = []
  var size = 160
  var i = 1
  while i < argv.count {
    let a = argv[i]
    switch a {
    case "-h", "--help":
      throw ArgError.help
    case "--size":
      i += 1
      guard i < argv.count, let n = Int(argv[i]), n > 0 else {
        throw ArgError.badSize(i < argv.count ? argv[i] : "")
      }
      size = n
    default:
      if a.hasPrefix("-") { throw ArgError.unknownFlag(a) }
      positionals.append(a)
    }
    i += 1
  }
  guard let input = positionals.first else { throw ArgError.missingInput }
  let output = positionals.count > 1 ? positionals[1] : nil
  return Options(input: input, output: output, size: size)
}

/// Choose the output path: explicit wins; else `<alias>.png`; else `emoji.png`.
public func outputName(explicit: String?, aliasName: String?) -> String {
  if let explicit { return explicit }
  if let aliasName { return "\(aliasName).png" }
  return "emoji.png"
}
