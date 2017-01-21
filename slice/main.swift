//
//  main.swift
//  slice
//
//  Created by Dylan Wreggelsworth on 1/21/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Cocoa

let cli = CommandLine()

let rowsOpt = IntOption(shortFlag: "r",
                     longFlag: "rows",
                     helpMessage: "Defines how many rows to slice the image into. Default: 3")

let columnsOpt = IntOption(shortFlag: "c",
                        longFlag: "cols",
                        helpMessage: "Defines how many columns to slice the image into. Default: 3")

let retinaOpt = BoolOption(longFlag: "retina",
                        helpMessage: "Output retina images.")

let outputFolderOpt = StringOption(shortFlag: "o",
                                longFlag: "output",
                                helpMessage: "Path to output directory. Default: .")

let helpOpt = BoolOption(shortFlag: "h",
                      longFlag: "help",
                      helpMessage: "Prints a help message.")

cli.addOptions(rowsOpt, columnsOpt, outputFolderOpt, retinaOpt, helpOpt)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let files = cli.unparsedArguments

guard files.count > 0 else {
    cli.printUsage()
    exit(EX_USAGE)
}

let rows = rowsOpt.value ?? 3
let columns = columnsOpt.value ?? 3

func save(slices: [NSImage]?, from file: URL) {
    guard let imageSlices = slices else {
        return
    }

    var offset = 0
    for r in 0..<rows {
        for c in 0..<columns {
            let slicedImage = imageSlices[offset]

            let rLabel      = "r\(r)"
            let cLabel      = "c\(c)"
            let name        = "\(file.basename)-\(rLabel)-\(cLabel)"
            let oneXName    = "\(name)\(file.ext)"

            slicedImage.save(to: URL(fileURLWithPath: oneXName))

            if retinaOpt.value {
                let twoXName    = "\(name)\(file.twoXext)"
                let twoXSize = AffineTransform(scale: 2.0).transform(slicedImage.size)
                slicedImage
                    .resize(to: twoXSize)?
                    .save(to: URL(fileURLWithPath: twoXName))

                let threeXName  = "\(name)\(file.threeXext)"
                let threeXSize = AffineTransform(scale: 3.0).transform(slicedImage.size)
                slicedImage
                    .resize(to: threeXSize)?
                    .save(to: URL(fileURLWithPath: threeXName))
            }

            offset += 1
        }
    }
}

let slicedImages = files.map({ (fileName) -> [NSImage]? in
    let file = URL(fileURLWithPath: fileName)

    guard file.exists == true else {
        print("Skipping \(fileName) since it doesn't exist...")
        return nil
    }

    guard file.isDirectory == false  else {
        print("Skipping \(fileName) since it's a directory...")
        return nil
    }

    guard let image = NSImage(contentsOf: file) else {
        print("Error loading \(fileName), skipping...")
        return nil
    }

    return image.slice(rows: rows, cols: columns)
})

// Convert all files to URLs...
let urls = files.map({ URL(fileURLWithPath: $0) })

// Correlate sliced images with urls and save them...
zip(slicedImages, urls).forEach(save)
