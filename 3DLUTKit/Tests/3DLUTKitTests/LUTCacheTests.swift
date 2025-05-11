//
//  LUTCacheTests.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import Testing
import Foundation
import CoreGraphics
@testable import _DLUTKit

struct LUTCacheTests {
    // Вспомогательная функция для создания тестового LUTModel
    private func createTestLUTModel(url: URL, title: String = "TestLUT", cubeDataSize: Int = 1024, dimension: Float = 17.0) -> LUTModel {
        let cubeData = Data(repeating: 0, count: cubeDataSize)
        return LUTModel(
            url: url,
            title: title,
            description: "Test Description",
            cubeData: cubeData,
            dimension: dimension,
            range: 0...1,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
    }
    
    @Test func testGetLUT() async throws {
        let cache = LUTCache.shared
        let url = URL(fileURLWithPath: "/test/lut1.cube")
        let lut = createTestLUTModel(url: url)
        
        // Проверяем, что кэш пуст
        let result = await cache.getLUT(for: url)
        #expect(result == nil, "Cache should return nil for non-existent LUT")
        
        // Добавляем LUT и проверяем получение
        await cache.setLUT(lut, for: url)
        let cachedLUT = await cache.getLUT(for: url)
        #expect(cachedLUT != nil, "Cache should return the stored LUT")
        #expect(cachedLUT?.title == lut.title, "Cached LUT title should match")
    }
    
    @Test func testSetLUTUpdatesAccessOrder() async throws {
        let cache = LUTCache.shared
        let url1 = URL(fileURLWithPath: "/test/lut1.cube")
        let url2 = URL(fileURLWithPath: "/test/lut2.cube")
        let lut1 = createTestLUTModel(url: url1, title: "LUT1")
        let lut2 = createTestLUTModel(url: url2, title: "LUT2")
        
        // Добавляем два LUT
        await cache.setLUT(lut1, for: url1)
        await cache.setLUT(lut2, for: url2)
        
        // Проверяем, что получение LUT1 обновляет порядок доступа
        let _ = await cache.getLUT(for: url1)
        await cache.setLUT(lut1, for: url1) // Повторное добавление
        let cachedLUT = await cache.getLUT(for: url1)
        #expect(cachedLUT?.title == "LUT1", "LUT1 should still be accessible")
    }
    
    @Test func testMaxCountLimit() async throws {
        let cache = LUTCache.shared
        let maxCount = 100 // Ограничение из LUTCache
        
        // Добавляем 101 LUT
        for i in 0...maxCount {
            let url = URL(fileURLWithPath: "/test/lut\(i).cube")
            let lut = createTestLUTModel(url: url, title: "LUT\(i)", cubeDataSize: 100)
            await cache.setLUT(lut, for: url)
        }
        
        // Проверяем, что первый LUT удален
        let firstLUT = await cache.getLUT(for: URL(fileURLWithPath: "/test/lut0.cube"))
        #expect(firstLUT == nil, "Oldest LUT should be removed due to maxCount limit")
        
        // Проверяем, что последний LUT доступен
        let lastLUT = await cache.getLUT(for: URL(fileURLWithPath: "/test/lut100.cube"))
        #expect(lastLUT != nil, "Newest LUT should be available")
    }
    
    @Test func testMaxSizeLimit() async throws {
        let cache = LUTCache.shared
        let largeSize = 30 * 1024 * 1024 // 30 МБ
        let url1 = URL(fileURLWithPath: "/test/large1.cube")
        let url2 = URL(fileURLWithPath: "/test/large2.cube")
        let lut1 = createTestLUTModel(url: url1, title: "LargeLUT1", cubeDataSize: largeSize)
        let lut2 = createTestLUTModel(url: url2, title: "LargeLUT2", cubeDataSize: largeSize)
        
        // Добавляем первый LUT
        await cache.setLUT(lut1, for: url1)
        // Добавляем второй LUT, что превысит maxSize (50 МБ)
        await cache.setLUT(lut2, for: url2)
        
        // Проверяем, что первый LUT удален
        let cachedLUT1 = await cache.getLUT(for: url1)
        #expect(cachedLUT1 == nil, "First LUT should be removed due to maxSize limit")
        
        // Проверяем, что второй LUT доступен
        let cachedLUT2 = await cache.getLUT(for: url2)
        #expect(cachedLUT2 != nil, "Second LUT should be available")
    }
    
    @Test func testClearCache() async throws {
        let cache = LUTCache.shared
        let url = URL(fileURLWithPath: "/test/lut.cube")
        let lut = createTestLUTModel(url: url)
        
        // Добавляем LUT
        await cache.setLUT(lut, for: url)
        let cachedLUT = await cache.getLUT(for: url)
        #expect(cachedLUT != nil, "LUT should be available before clearing")
        
        // Очищаем кэш
        await cache.clearCache()
        
        // Проверяем, что кэш пуст
        let result = await cache.getLUT(for: url)
        #expect(result == nil, "Cache should be empty after clearing")
    }
    
    @Test func testRealLUTFile() async throws {
        let cache = LUTCache.shared
        guard let cubeURL = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube") else {
            throw TestError.resourceNotFound("Kodachrome 25.cube")
        }
        
        // Создаем LUTModel из реального файла
        let lut = try LUTModel(url: cubeURL)
        
        // Добавляем в кэш
        await cache.setLUT(lut, for: cubeURL)
        
        // Проверяем, что LUT доступен
        let cachedLUT = await cache.getLUT(for: cubeURL)
        #expect(cachedLUT != nil, "Real LUT should be cached")
        #expect(cachedLUT?.title == "Kodachrome 25")
    }
}
