//
//  LUTModel.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

/// A model representing a 3D Look-Up Table (LUT) for applying color transformations to images.
///
/// `LUTModel` encapsulates the data and metadata of a 3D LUT, which is used to map input RGB colors to output RGB colors for color grading or correction. The LUT can be created from a `.cube` file or a `.png` image (palette format). It provides a convenient interface for generating a Core Image filter (`CIColorCubeWithColorSpace`) to apply the LUT to images.
///
/// - Parameters:
///   - url: The URL of the `.cube` or `.png` file from which the LUT is created.
///   - title: A human-readable name for the LUT, typically derived from the file name or metadata.
///   - description: Additional information about the LUT, such as comments from a `.cube` file.
///   - cubeData: The raw data of the LUT in RGBA format, stored as a `Data` object.
///   - dimension: The size of the LUT cube (e.g., 17 for a 17x17x17 LUT).
///   - range: An optional range for input values, typically `[0.0, 1.0]` for `.cube` files.
///   - colorSpace: The color space used for the LUT, either `sRGB` or `displayP3`.
///
/// ### Properties
/// - `id`: A unique identifier based on the `url` of the LUT.
/// - `dataSize`: The expected size of `cubeData` in bytes, calculated as `dimension * dimension * dimension * 4 * sizeof(Float)`.
/// - `ciFilter`: An optional `CIFilter` (`CIColorCubeWithColorSpace`) configured with the LUT's data, ready to be applied to images.
///
/// ### Usage
/// To create a LUT from a `.cube` file and apply it to an image:
/// ```swift
/// let url = Bundle.main.url(forResource: "Kodachrome 25", withExtension: "cube")!
/// do {
///     let lut = try LUTModel(url: url)
///     let filter = lut.ciFilter
///     // Use filter with FilteredImage or Core Image pipeline
/// } catch {
///     print("Failed to create LUT: \(error)")
/// }
/// ```
///
/// To use a predefined preview LUT:
/// ```swift
/// let lut = LUTModel.previewCube
/// let filter = lut.ciFilter
/// // Apply filter to an image
/// ```
///
/// ### Supported Formats
/// - `.cube`: Industry-standard text-based LUT format with metadata and RGB values.
/// - `.png`: Palette-based LUT images in RGB or RGBA format, where the image dimensions form a cube (e.g., 512x64 for a 64x64x64 LUT).
///
/// ### Supported Color Spaces
/// - `sRGB`: Standard RGB color space, widely used for compatibility.
/// - `displayP3`: Wide-gamut color space for modern displays, providing richer colors.
///
/// ### Notes
/// - The LUT data is stored in RGBA format, with the alpha channel set to `1.0` for all entries.
/// - The color space defaults to `sRGB` if not specified in the file metadata or ICC profile.
/// - Errors during LUT creation (e.g., invalid file format, missing dimension) are thrown as `LUTError`.
/// - The `previewCube` and `previewPng` properties provide sample LUTs for testing, loaded from the module's bundle.
/// - Ensure the input image's color space is compatible with the LUT's color space for accurate results.
public struct LUTModel: Identifiable, Hashable, Sendable {
    public let url: URL
    public let title: String
    public let description: String
    public let cubeData: Data
    public let dimension: Float
    public let range: ClosedRange<Float>?
    public let colorSpace: LUTColorSpace
    
    public var id: String { url.absoluteString }
    public var dataSize: Int {
        Int(dimension * dimension * dimension * 4 * Float(MemoryLayout<Float>.size))
    }
}

extension LUTModel {
    /// Initializes a LUT model synchronously from a file URL without using the cache.
    public init(url: URL) throws {
        let model = try Self.build(from: url)
        self.url = url
        self.title = model.title
        self.description = model.description
        self.cubeData = model.cubeData
        self.dimension = model.dimension
        self.range = model.range
        self.colorSpace = model.colorSpace
    }
    
    /// Initializes a LUT model asynchronously from a file URL, optionally using the cache.
    public init(url: URL, useCache: Bool = true) async throws {
        // Проверяем, есть ли LUT в кэше
        if useCache, let cachedLUT = await LUTCache.shared.getLUT(for: url) {
            self = cachedLUT
            return
        }
        
        // Если нет в кэше, создаем новую модель
        let model = try Self.build(from: url)
        self.url = url
        self.title = model.title
        self.description = model.description
        self.cubeData = model.cubeData
        self.dimension = model.dimension
        self.range = model.range
        self.colorSpace = model.colorSpace
        
        // Сохраняем в кэш
        if useCache {
            try await LUTCache.shared.setLUT(self, for: url)
        }
    }
    
    public static func build(from url: URL) throws -> LUTModel {
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
    static let previewCube: LUTModel = {
        guard let url = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube") else {
            fatalError("Kodachrome 25.cube not found in bundle")
        }
        do {
            return try .init(url: url)
        } catch {
            fatalError("Failed to create previewCube: \(error)")
        }
    }()
    
    static let previewPng: LUTModel = {
        guard let url = Bundle.module.url(forResource: "teal_orange_plus_contrast", withExtension: "png") else {
            fatalError("teal_orange_plus_contrast.png not found in bundle")
        }
        do {
            return try .init(url: url)
        } catch {
            fatalError("Failed to create previewPng: \(error)")
        }
    }()
}
