//
//  LUTModel.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation
import CoreGraphics
import CoreImage

public struct LUTModel: Identifiable, Hashable, Sendable {
    public let url: URL
    public let title: String
    public let description: String
    public let cubeData: Data
    public let dimension: Float
    public let range: ClosedRange<Float>?
    public let colorSpace: CGColorSpace
    
    public var id: String { url.absoluteString }
    public var dataSize: Int {
        Int(dimension * dimension * dimension * 4 * Float(MemoryLayout<Float>.size))
    }
    public var ciFilter: CIFilter? {
        try? CIFilter(lut: self)
    }
}

extension LUTModel {
    init(url: URL) throws {
        let model = try Self.build(from: url)
        self.url = url
        self.title = model.title
        self.description = model.description
        self.cubeData = model.cubeData
        self.dimension = model.dimension
        self.range = model.range
        self.colorSpace = model.colorSpace
    }
    
    static func build(from url: URL) throws -> LUTModel {
        let type = LUTType(url: url)
        switch type {
        case .cube:
            return try CUBEUtil.buildLUT(from: url)
        case .palette:
            return try PNGUtil.buildLUT(from: url)
        case nil:
            throw LUTError.fileNotSupported(url.lastPathComponent)
        }
    }
}

public extension LUTModel {
    static let preview: LUTModel = try! .init(url: Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube")!)
}
