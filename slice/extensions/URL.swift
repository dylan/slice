//
//  URL.swift
//  slice
//
//  Created by Dylan Wreggelsworth on 1/21/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//
import Foundation

extension URL {

    var basename: String {
        return self.deletingPathExtension().lastPathComponent
    }

    var standardizedPath: String {
        return self.deletingLastPathComponent().standardized.path
    }

    var name: String {
        return self.lastPathComponent
    }

    var ext: String {
        return ".\(self.pathExtension)"
    }

    var twoXext: String {
        return "@2x\(ext)"
    }

    var threeXext: String {
        return "@3x\(ext)"
    }

    var twoXname: String {
        return basename + twoXext
    }

    var threeXname: String {
        return basename + threeXext
    }

    var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    var isDirectory: Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return (attributes[.type] as? FileAttributeType) == .typeDirectory ? true : false
        }
        catch {
            print(error)
        }
        return false
    }

}
