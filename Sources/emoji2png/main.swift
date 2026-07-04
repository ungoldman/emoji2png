import EmojiToPNGCore
import Foundation

let usage = "usage: emoji2png <emoji|alias> [output.png] [--size N]"

func die(_ message: String, _ code: Int32) -> Never {
  FileHandle.standardError.write(Data((message + "\n").utf8))
  exit(code)
}

let options: Options
do {
  options = try parseArguments(CommandLine.arguments)
} catch ArgError.help {
  print(usage)
  exit(0)
} catch let ArgError.badSize(v) {
  die("emoji2png: invalid --size '\(v)' (want a positive integer)\n" + usage, 2)
} catch let ArgError.unknownFlag(f) {
  die("emoji2png: unknown flag '\(f)'\n" + usage, 2)
} catch ArgError.missingInput {
  die(usage, 2)
} catch {
  die("emoji2png: \(error)\n" + usage, 2)
}

guard let resolution = resolveEmoji(options.input) else {
  die("emoji2png: unknown emoji or alias '\(options.input)'", 1)
}

let out = outputName(explicit: options.output, aliasName: resolution.aliasName)
do {
  let data = try renderPNG(resolution.emoji, size: options.size)
  try data.write(to: URL(fileURLWithPath: out))
  print("wrote \(out) (\(options.size)x\(options.size))")
} catch RenderError.noInk {
  die("emoji2png: '\(options.input)' produced no image", 1)
} catch {
  die("emoji2png: could not write \(out): \(error)", 1)
}
