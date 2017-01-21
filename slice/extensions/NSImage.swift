//
//  NSImage.swift
//  slice
//
//  Created by Dylan Wreggelsworth on 1/21/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Cocoa

extension NSImage {
    func slice(rows: Int, cols: Int) -> [NSImage] {

        let srcWidth    = Int(self.size.width)
        let srcHeight   = Int(self.size.height)

        let sliceWidth  = srcWidth / rows
        let sliceHeight = srcHeight / cols

        let sliceSize   = NSSize(width: sliceWidth, height: sliceHeight)

        var results = [NSImage]()
        for row in (0..<rows).reversed() {
            for col in (0..<cols) {
                let offsetPoint = CGPoint(x: col * sliceWidth, y: row * sliceHeight)
                let sourceRect = NSRect(origin: offsetPoint, size: sliceSize)

                let resultImage = NSImage(size: sliceSize, flipped: false) { _ in
                    NSGraphicsContext.current()?.imageInterpolation = .none
                    self.draw(at: CGPoint(), from: sourceRect, operation: .copy, fraction: 1.0)
                    return true
                }

                results.append(resultImage)
            }
        }

        return results
    }

    func resize(to size: NSSize) -> NSImage? {
        guard self.isValid else {
            return nil
        }
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(size.width),
                                         pixelsHigh: Int(size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: NSCalibratedRGBColorSpace,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else { return nil }
        rep.size = size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: rep))
        NSGraphicsContext.current()?.imageInterpolation = .none
        self.draw(in: NSRect(x:0, y: 0, width: size.width, height: size.height), from: NSRect(), operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        let result = NSImage(size: size)
        result.addRepresentation(rep)
        return result
    }

    func save(to url: URL) {
        guard let tiffData = self.tiffRepresentation,
            let bref = NSBitmapImageRep(data: tiffData) else {
                fatalError("Problem pulling bitmap data!")
        }
        bref.savePNG(to: url)
    }
}
