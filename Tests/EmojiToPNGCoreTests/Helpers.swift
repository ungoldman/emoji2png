import CoreGraphics
import Foundation
import ImageIO

func pngSize(_ data: Data) -> (width: Int, height: Int)? {
  guard let src = CGImageSourceCreateWithData(data as CFData, nil),
        let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
  return (img.width, img.height)
}

/// Decode a PNG to a tight RGBA byte buffer plus its dimensions.
func pngPixels(_ data: Data) -> (px: [UInt8], w: Int, h: Int)? {
  guard let src = CGImageSourceCreateWithData(data as CFData, nil),
        let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
  let w = img.width, h = img.height
  var buf = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = buf.withUnsafeMutableBytes { raw in
    CGContext(data: raw.baseAddress, width: w, height: h, bitsPerComponent: 8,
              bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
  }
  ctx?.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
  return (buf, w, h)
}

func alpha(_ px: [UInt8], _ w: Int, _ x: Int, _ y: Int) -> UInt8 {
  px[(y * w + x) * 4 + 3]
}
