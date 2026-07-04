import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum RenderError: Error, Equatable {
  case noInk
  case invalidSize
}

/// Render `text` to a trimmed, centered, transparent `size` x `size` PNG using
/// the system Apple Color Emoji font. Throws `.invalidSize` if `size <= 0`,
/// `.noInk` if nothing is drawn.
public func renderPNG(_ text: String, size: Int) throws -> Data {
  guard size > 0 else { throw RenderError.invalidSize }
  let renderPt = Double(max(size, 160))
  let font = CTFontCreateWithName("Apple Color Emoji" as CFString, renderPt, nil)
  let attrs = [NSAttributedString.Key(kCTFontAttributeName as String): font]
  let line = CTLineCreateWithAttributedString(
    NSAttributedString(string: text, attributes: attrs))

  func context(_ w: Int, _ h: Int) -> CGContext {
    CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
              bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  }

  let pad = Int(renderPt)
  let side = Int(renderPt) + pad * 2
  let big = context(side, side)
  big.textPosition = CGPoint(x: Double(pad), y: Double(pad))
  CTLineDraw(line, big)

  // Tight alpha bounding box, read straight from the context buffer.
  let w = big.width, h = big.height, bpr = big.bytesPerRow
  let ptr = big.data!.assumingMemoryBound(to: UInt8.self)
  var minX = w, minY = h, maxX = -1, maxY = -1
  for y in 0..<h {
    for x in 0..<w where ptr[y * bpr + x * 4 + 3] > 0 {
      if x < minX { minX = x }
      if x > maxX { maxX = x }
      if y < minY { minY = y }
      if y > maxY { maxY = y }
    }
  }
  guard maxX >= 0 else { throw RenderError.noInk }

  let cropW = maxX - minX + 1, cropH = maxY - minY + 1
  let glyph = big.makeImage()!.cropping(
    to: CGRect(x: minX, y: minY, width: cropW, height: cropH))!

  let scale = min(Double(size) / Double(cropW), Double(size) / Double(cropH), 1)
  let dw = Int((Double(cropW) * scale).rounded())
  let dh = Int((Double(cropH) * scale).rounded())
  let out = context(size, size)
  out.interpolationQuality = .high
  let ox = Int((Double(size - dw) / 2).rounded())
  let oy = Int((Double(size - dh) / 2).rounded())
  out.draw(glyph, in: CGRect(x: ox, y: oy, width: dw, height: dh))

  let data = NSMutableData()
  let dest = CGImageDestinationCreateWithData(
    data as CFMutableData, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, out.makeImage()!, nil)
  CGImageDestinationFinalize(dest)
  return data as Data
}
