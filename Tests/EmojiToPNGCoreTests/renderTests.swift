import Foundation
import Testing
@testable import EmojiToPNGCore

@Test func rendersRequestedDimensions() throws {
  let data = try renderPNG("🪨", size: 160)
  let size = pngSize(data)
  #expect(size?.width == 160)
  #expect(size?.height == 160)
}

@Test func hasTransparentCornersAndInk() throws {
  let data = try renderPNG("🪨", size: 160)
  let p = try #require(pngPixels(data))
  #expect(alpha(p.px, p.w, 0, 0) == 0)                 // corner transparent
  var inked = 0
  for i in stride(from: 3, to: p.px.count, by: 4) where p.px[i] > 0 { inked += 1 }
  #expect(inked > 0)                                    // glyph drew something
}

@Test func trimsAndCentersGlyph() throws {
  for size in [64, 160, 256] {
    let data = try renderPNG("🪨", size: size)
    let p = try #require(pngPixels(data))
    #expect(p.w == size && p.h == size)
    var minX = size, minY = size, maxX = -1, maxY = -1
    for y in 0..<p.h {
      for x in 0..<p.w where alpha(p.px, p.w, x, y) > 0 {
        if x < minX { minX = x }; if x > maxX { maxX = x }
        if y < minY { minY = y }; if y > maxY { maxY = y }
      }
    }
    #expect(maxX >= 0)                                   // has ink
    let bw = maxX - minX + 1, bh = maxY - minY + 1
    #expect(max(bw, bh) >= size * 9 / 10)               // trimmed tight: fills >=90% of a canvas axis
    #expect(abs(minX - (size - 1 - maxX)) <= 2)         // horizontally centered (symmetric margins)
    #expect(abs(minY - (size - 1 - maxY)) <= 2)         // vertically centered
  }
}

@Test func throwsNoInkForBlankInput() {
  #expect(throws: RenderError.noInk) {
    _ = try renderPNG(" ", size: 160)
  }
}

@Test func throwsInvalidSizeForNonPositive() {
  #expect(throws: RenderError.invalidSize) { _ = try renderPNG("🪨", size: 0) }
  #expect(throws: RenderError.invalidSize) { _ = try renderPNG("🪨", size: -5) }
}
