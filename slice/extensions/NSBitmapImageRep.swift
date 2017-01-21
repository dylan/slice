//
//  NSBitmapImageRep.swift
//  slice
//
//  Created by Dylan Wreggelsworth on 1/21/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Cocoa

extension NSBitmapImageRep {
    public func savePNG(to url: URL) {
        guard let png = self.representation(using: .PNG, properties: [:]) else {
            fatalError("Problem saving to PNG!")
        }
        do {
            try png.write(to:  url)
        } catch let error {
            fatalError("\(error))")
        }
    }
}
