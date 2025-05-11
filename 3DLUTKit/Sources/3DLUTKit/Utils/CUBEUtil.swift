//
//  CUBEUtil.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation
import CoreGraphics

struct CUBEUtil: Lookupable {
    static func buildLUT(from url: URL) throws -> LUTModel {
        let data = try Data(contentsOf: url)
        let content = String(data: data, encoding: .utf8) ?? ""
        let lines = content.components(separatedBy: .newlines)
        var values = [Float]()
        var dimension: Int?
        var title: String = "Unknown"
        var description: String = ""
        var range: ClosedRange<Float>?
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                description.append(trimmed + "\n")
                continue
            }
            
            if trimmed.lowercased().hasPrefix("title") {
                title = trimmed
                    .dropFirst(6)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\"", with: "")
                continue
            }
            
            if trimmed.lowercased().contains("lut_3d_size") {
                dimension = trimmed.split(separator: " ").last.flatMap { Int($0) }
                continue
            }
            if trimmed.lowercased().contains("lut_3d_input_range") {
                let components = trimmed.split(separator: " ").compactMap { Float($0) }
                if components.count >= 2 {
                    range = components[0]...components[1]
                }
                continue
            }
            let components = trimmed.split(separator: " ").compactMap { Float($0) }
            if components.count == 3 {
                values.append(contentsOf: components)
            }
        }
        
        guard let dimension else {
            throw LUTError.missingDimension
        }
        
        let expectedSize = dimension * dimension * dimension * 3
        if values.count < expectedSize {
            throw LUTError.invalidDataSize(expected: expectedSize, actual: values.count)
        }
        
        if values.count > expectedSize {
            print("⚠️ Предупреждение: LUT содержит лишние данные. Обрезаем...")
            values = Array(values.prefix(expectedSize))
        }
        
        var rgbaValues = [Float]()
        for i in stride(from: 0, to: values.count, by: 3) {
            rgbaValues.append(values[i])     // R
            rgbaValues.append(values[i + 1]) // G
            rgbaValues.append(values[i + 2]) // B
            rgbaValues.append(1.0)           // A
        }
        
        let lutData = Data(bytes: rgbaValues, count: rgbaValues.count * MemoryLayout<Float>.size)
        
        return LUTModel(
            url: url,
            title: title,
            description: description,
            cubeData: lutData,
            dimension: Float(dimension),
            range: range,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }
}
