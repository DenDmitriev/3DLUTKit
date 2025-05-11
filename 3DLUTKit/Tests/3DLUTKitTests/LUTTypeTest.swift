//
//  LUTTypeTest.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import Testing
import Foundation
@testable import _DLUTKit

struct LUTTypeTest {
    @Test func checkLUTTypeInit() throws {
        guard
            let cubeURL = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube"),
            let pngURL = Bundle.module.url(forResource: "fuji_eterna_250d_fuji_3510", withExtension: "png")
        else {
            throw TestError.resourceNotFound("")
        }
        
        let pngType = LUTType(url: pngURL)
        #expect(pngType == .palette)
        
        let cubeType = LUTType(url: cubeURL)
        #expect(cubeType == .cube)
    }
}
