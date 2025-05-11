//
//  File.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import Testing
import Foundation
@testable import _DLUTKit
import CoreImage

struct CIFilterTests {
    @Test("Инициализация CIFilter с LUTModel")
    func checkInitFilter() async throws {
        // Загружаем тестовый .cube файл
        guard let url = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube") else {
            throw TestError.resourceNotFound("Kodachrome 25.cube")
        }
        
        // Создаем LUTModel
        let lutModel = try CUBEUtil.buildLUT(from: url)
        
        // Инициализируем CIFilter
        let filter = try CIFilter(lut: lutModel)
        
        // Проверяем свойства фильтра
        #expect(filter.name == "CIColorCubeWithColorSpace", "Фильтр должен быть CIColorCubeWithColorSpace")
        
        let dimension = try #require(filter.value(forKey: "inputCubeDimension") as? Float, "inputCubeDimension должен быть установлен")
        #expect(dimension == lutModel.dimension, "inputCubeDimension должен соответствовать dimension из LUTModel")
        
        let cubeData = try #require(filter.value(forKey: "inputCubeData") as? Data, "inputCubeData должен быть установлен")
        #expect(cubeData == lutModel.cubeData, "inputCubeData должен соответствовать cubeData из LUTModel")
        
        let colorSpace = try #require(filter.value(forKey: "inputColorSpace"), "inputColorSpace должен быть установлен")
        #expect(colorSpace as! CGColorSpace == lutModel.colorSpace, "inputColorSpace должен соответствовать colorSpace из LUTModel")
        
        // Проверяем, что фильтр готов к использованию
        #expect(filter.inputKeys.contains(kCIInputImageKey), "Фильтр должен поддерживать inputImage")
    }
}
