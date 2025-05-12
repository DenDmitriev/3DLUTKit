//
//  LUTCache.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

actor LUTCache {
    static let shared = LUTCache()
    private var cache: [URL: LUTModel] = [:]
    private var accessOrder: [URL] = []
    private var totalSize: Int = 0 // Размер в байтах
    private let maxSize: Int = 50 * 1024 * 1024 // 50 МБ
    private let maxCount: Int = 100 // Ограничение по количеству
    
    private init() {}
    
    func getLUT(for url: URL) -> LUTModel? {
        if let lut = cache[url] {
            accessOrder.removeAll { $0 == url }
            accessOrder.append(url)
            return lut
        }
        return nil
    }
    
    func setLUT(_ lut: LUTModel, for url: URL) throws {
        let lutSize = lut.cubeData.count + MemoryLayout<URL>.size + lut.title.utf8.count + lut.description.utf8.count + MemoryLayout<Float>.size * 2 + MemoryLayout<LUTColorSpace>.size
        
        guard lutSize <= maxSize else {
            throw LUTError.invalidDataSize(expected: maxSize, actual: lutSize)
        }
        
        while totalSize + lutSize > maxSize || cache.count >= maxCount, !accessOrder.isEmpty {
            let oldest = accessOrder.removeFirst()
            if let oldLUT = cache.removeValue(forKey: oldest) {
                let oldSize = oldLUT.cubeData.count + MemoryLayout<URL>.size + oldLUT.title.utf8.count + oldLUT.description.utf8.count + MemoryLayout<Float>.size * 2 + MemoryLayout<LUTColorSpace>.size
                totalSize -= oldSize
            }
        }
        
        cache[url] = lut
        accessOrder.append(url)
        totalSize += lutSize
    }
    
    func clearCache() {
        cache.removeAll()
        accessOrder.removeAll()
        totalSize = 0
    }
}
