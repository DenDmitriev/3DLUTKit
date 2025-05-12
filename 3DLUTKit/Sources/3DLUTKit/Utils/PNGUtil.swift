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
        
        // Создаем CGImage с использованием CIContextManager для потокобезопасности
        guard let cgImage = CIContextManager.shared.withContext({ context in
            context.createCGImage(inputImage, from: inputImage.extent)
        }) else {
            throw LUTError.invalidImage
        }
        
        // Проверяем формат изображения
        guard cgImage.bitsPerComponent == 8 else {
            throw LUTError.invalidFormat("Only 8-bit per channel PNG images are supported")
        }
        
        let bitsPerPixel = cgImage.bitsPerPixel
        let alphaInfo = cgImage.alphaInfo
        let bytesPerPixel: Int
        let hasAlpha: Bool
        
        switch (bitsPerPixel, alphaInfo) {
        case (24, .none), (24, .noneSkipLast):
            bytesPerPixel = 3
            hasAlpha = false
        case (32, .premultipliedLast), (32, .premultipliedFirst), (32, .first), (32, .last):
            bytesPerPixel = 4
            hasAlpha = true
        default:
            throw LUTError.invalidFormat("Unsupported PNG format. Only RGB or RGBA are supported")
        }
        
        guard let data = cgImage.dataProvider?.data as Data? else {
            throw LUTError.invalidImage
        }
        
        let title = prettifyFileName(url.lastPathComponent)
        
        let pixelsCount = width * height
        let dimension = Int(round(pow(Double(pixelsCount), 1.0/3.0)))
        
        guard dimension * dimension * dimension == pixelsCount else {
            throw LUTError.invalidFormat("PNG dimensions do not form a valid LUT cube")
        }
        
        let bytes = data.withUnsafeBytes { Array($0) }
        var floatValues = [Float]()
        floatValues.reserveCapacity(dimension * dimension * dimension * 4)
        
        for blue in 0..<dimension {
            for green in 0..<dimension {
                for red in 0..<dimension {
                    let x = red + (blue % 8) * dimension
                    let y = green + (blue / 8) * dimension
                    let index = (y * width + x) * bytesPerPixel
                    
                    let r = Float(bytes[index]) / 255.0
                    let g = Float(bytes[index + 1]) / 255.0
                    let b = Float(bytes[index + 2]) / 255.0
                    let a = hasAlpha ? Float(bytes[index + 3]) / 255.0 : 1.0
                    
                    guard [r, g, b, a].allSatisfy({ $0 >= 0.0 && $0 <= 1.0 }) else {
                        throw LUTError.invalidLUTValue("Pixel values out of range at position (\(red), \(green), \(blue))")
                    }
                    
                    floatValues.append(contentsOf: [r, g, b, a])
                }
            }
        }
        
        let expectedCount = dimension * dimension * dimension * 4
        guard floatValues.count == expectedCount else {
            throw LUTError.invalidDataSize(expected: expectedCount, actual: floatValues.count)
        }
        
        let lutData = Data(bytes: floatValues, count: floatValues.count * MemoryLayout<Float>.size)
        
        // Определяем цветовое пространство
        var colorSpace: LUTColorSpace?
        if let cgColorSpace = cgImage.colorSpace, let name = cgColorSpace.name {
            colorSpace = LUTColorSpace(colorSpace: name)
        }
        
        return LUTModel(
            url: url,
            title: title,
            description: "Generated from PNG image",
            cubeData: lutData,
            dimension: Float(dimension),
            range: nil,
            colorSpace: colorSpace ?? .sRGB
        )
    }
}
