import Foundation
import Testing

// Swift Testing's runner isn't a discoverable .xctest bundle, so the usual
// Bundle.allBundles lookup finds nothing; derive the products directory (where
// SwiftPM built emoji2png) from the --test-bundle-path argument instead.
private var emoji2pngBinary: URL {
  guard let i = CommandLine.arguments.firstIndex(of: "--test-bundle-path"),
        CommandLine.arguments.indices.contains(i + 1) else {
    fatalError("could not locate --test-bundle-path to find the built emoji2png binary")
  }
  var url = URL(fileURLWithPath: CommandLine.arguments[i + 1])
  while url.pathExtension != "xctest", url.path != "/" {
    url.deleteLastPathComponent()
  }
  return url.deletingLastPathComponent().appendingPathComponent("emoji2png")
}

private func runCLI(_ args: [String]) -> (code: Int32, err: String) {
  let p = Process()
  p.executableURL = emoji2pngBinary
  p.arguments = args
  let errPipe = Pipe()
  p.standardError = errPipe
  p.standardOutput = Pipe()
  try! p.run()
  p.waitUntilExit()
  let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(),
                   encoding: .utf8) ?? ""
  return (p.terminationStatus, err)
}

@Test func writesFileForAlias() throws {
  let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
  defer { try? FileManager.default.removeItem(at: tmp) }
  let out = tmp.appendingPathComponent("r.png")
  let r = runCLI(["rocket", out.path])
  #expect(r.code == 0)
  #expect(FileManager.default.fileExists(atPath: out.path))
}

@Test func exitsTwoOnMissingInput() {
  let r = runCLI([])
  #expect(r.code == 2)
  #expect(r.err.contains("usage"))
}

@Test func exitsOneOnUnknownAlias() {
  let r = runCLI(["definitelynotanemoji"])
  #expect(r.code == 1)
}
