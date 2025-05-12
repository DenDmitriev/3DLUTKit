//
//  LUTModel+CIFilter.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 12.05.2025.
//

import CoreGraphics
import CoreImage

extension LUTModel {
    public var ciFilter: CIFilter? {
        try? CIFilter(lut: self)
    }
}
