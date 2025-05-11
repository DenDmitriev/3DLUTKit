//
//  CIFilter+LUTFilter.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import CoreImage

extension CIFilter {
    @Sendable
    static func createLUTFilter(lutModel: LUTModel) throws -> CIFilter {
        guard lutModel.cubeData.count == lutModel.dataSize else {
            throw LUTError.invalidDataSize(expected: lutModel.dataSize, actual: lutModel.cubeData.count)
        }

        guard let colorCubeFilter = CIFilter(name: "CIColorCubeWithColorSpace") else {
            throw LUTError.filterCreationFailed
        }

        colorCubeFilter.setValue(lutModel.dimension, forKey: "inputCubeDimension")
        colorCubeFilter.setValue(lutModel.cubeData, forKey: "inputCubeData")
        colorCubeFilter.setValue(lutModel.colorSpace, forKey: "inputColorSpace")

        return colorCubeFilter
    }
}
