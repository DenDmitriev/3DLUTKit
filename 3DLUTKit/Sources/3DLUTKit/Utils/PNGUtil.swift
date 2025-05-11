//
//  PNGUtil.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import CoreImage
import CoreGraphics

struct PNGUtil: Lookupable {
    static func buildLUT(from url: URL) throws -> LUTModel {
        guard let inputImage = CIImage(contentsOf: url) else {
            throw LUTError.invalidImage
        }
        
        let width = Int(inputImage.extent.width)
        let height = Int(inputImage.extent.height)
        
        guard let cgImage = CIContextManager.shared.createCGImage(inputImage, from: inputImage.extent) else {
            throw LUTError.invalidImage
        }
        
        guard let data = cgImage.dataProvider?.data as Data? else {
            throw LUTError.invalidImage
        }
        
        let title = prettifyFileName(url.lastPathComponent)
        
        let pixelsCount = width * height
        let dimension = Int(round(pow(Double(pixelsCount), 1.0/3.0)))
        let bytes = data.withUnsafeBytes { Array($0) }
        var floatValues: [Float] = []
        
        let bytesPerPixel = 4
        for blue in 0..<dimension {
            for green in 0..<dimension {
                for red in 0..<dimension {
                    let x = red + (blue % 8) * dimension
                    let y = green + (blue / 8) * dimension
                    let index = (y * width + x) * bytesPerPixel
                    
                    let r = Float(bytes[index]) / 255.0
                    let g = Float(bytes[index + 1]) / 255.0
                    let b = Float(bytes[index + 2]) / 255.0
                    floatValues.append(contentsOf: [r, g, b, 1.0])
                }
            }
        }
        
        let expectedCount = dimension * dimension * dimension * 4
        guard floatValues.count == expectedCount else {
            throw LUTError.invalidDataSize(expected: expectedCount, actual: floatValues.count)
        }
        
        let lutData = Data(bytes: floatValues, count: floatValues.count * MemoryLayout<Float>.size)
        
        return LUTModel(
            url: url,
            title: title,
            description: "Generated from PNG image",
            cubeData: lutData,
            dimension: Float(dimension),
            range: nil,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }
}
