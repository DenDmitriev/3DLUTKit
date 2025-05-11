//
//  CIFilter+LUTFilter.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import CoreImage

extension CIFilter {
    convenience public init(lut: LUTModel) throws {
        guard lut.cubeData.count == lut.dataSize else {
            throw LUTError.invalidDataSize(expected: lut.dataSize, actual: lut.cubeData.count)
        }
        
        guard let _ = CIFilter(name: "CIColorCubeWithColorSpace") else {
            throw LUTError.filterCreationFailed
        }
        
        self.init(name: "CIColorCubeWithColorSpace")!
        setValue(lut.dimension, forKey: "inputCubeDimension")
        setValue(lut.cubeData, forKey: "inputCubeData")
        setValue(lut.colorSpace, forKey: "inputColorSpace")
    }
    
    @Sendable
    static func createLUTFilter(lut: LUTModel) throws -> CIFilter {
        guard lut.cubeData.count == lut.dataSize else {
            throw LUTError.invalidDataSize(expected: lut.dataSize, actual: lut.cubeData.count)
        }
        
        guard let colorCubeFilter = CIFilter(name: "CIColorCubeWithColorSpace") else {
            throw LUTError.filterCreationFailed
        }
        
        colorCubeFilter.setValue(lut.dimension, forKey: "inputCubeDimension")
        colorCubeFilter.setValue(lut.cubeData, forKey: "inputCubeData")
        colorCubeFilter.setValue(lut.colorSpace, forKey: "inputColorSpace")
        
        return colorCubeFilter
    }
}
