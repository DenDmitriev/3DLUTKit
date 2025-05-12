//
//  LUTColorSpace.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 12.05.2025.
//

import CoreGraphics

/// Supported color spaces for LUT processing.
///
/// Defines the color spaces used by `LUTModel` for color transformations.
/// - `sRGB`: Standard RGB color space for compatibility.
/// - `displayP3`: Wide-gamut color space for modern displays.
public enum LUTColorSpace: String, CaseIterable, Sendable {
    case sRGB = "sRGB"
    case displayP3 = "displayP3"
    
    /// Returns the corresponding `CGColorSpace` for the LUT color space.
    var cgColorSpace: CGColorSpace {
        switch self {
        case .sRGB:
            return CGColorSpace(name: CGColorSpace.sRGB)!
        case .displayP3:
            return CGColorSpace(name: CGColorSpace.displayP3)!
        }
    }
}

extension LUTColorSpace {
    /// Initializes a `LUTColorSpace` from a string identifier.
    /// - Parameter identifier: The string identifier (e.g., "sRGB", "displayP3").
    init?(identifier: String) {
        let normalized = identifier.lowercased()
        if let colorSpace = LUTColorSpace.allCases.first(where: { $0.rawValue.lowercased() == normalized }) {
            self = colorSpace
        } else {
            return nil
        }
    }
    
    init?(colorSpace: CFString) {
        switch colorSpace {
        case _ where colorSpace == CGColorSpace.sRGB:
            self = .sRGB
        case _ where colorSpace == CGColorSpace.displayP3:
            self = .displayP3
        default:
            self = .sRGB
        }
    }
}
