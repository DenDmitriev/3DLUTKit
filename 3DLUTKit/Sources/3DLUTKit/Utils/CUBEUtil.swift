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
        var dimension: Int?
        var title: String = "Unknown"
        var description: String = ""
        var range: ClosedRange<Float>?
        var colorSpace: LUTColorSpace = .sRGB // Default
        var firstDataLineIndex = 0
        
        // Первый цикл: сбор метаданных
        for (index, line) in lines.enumerated() {
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
            
            if trimmed.lowercased().hasPrefix("color_space") {
                let components = trimmed.split(separator: " ")
                if components.count > 1, let cs = LUTColorSpace(identifier: String(components[1])) {
                    colorSpace = cs
                }
                continue
            }
            
            // Прерываем цикл, если встретили строку с данными LUT
            if trimmed.split(separator: " ").compactMap({ Float($0) }).count == 3 {
                firstDataLineIndex = index
                break
            }
        }
        
        // Проверяем dimension и выделяем память
        guard let dimension, dimension > 0, dimension <= 256 else {
            throw LUTError.missingDimension
        }
        let expectedSize = dimension * dimension * dimension * 3
        var values = [Float]()
        values.reserveCapacity(expectedSize)
        
        // Второй цикл: сбор значений LUT
        for line in lines[firstDataLineIndex...] {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let components = trimmed.split(separator: " ").compactMap { Float($0) }
            if components.count == 3, components.allSatisfy({ $0.isFinite }) {
                values.append(contentsOf: components)
            }
        }
        
        // Проверка размера и обрезка
        if values.count < expectedSize {
            throw LUTError.invalidDataSize(expected: expectedSize, actual: values.count)
        }
        
        if values.count > expectedSize {
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
            colorSpace: colorSpace
        )
    }
}
