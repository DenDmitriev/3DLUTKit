//
//  PNGUtilTests.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import Testing
import Foundation
@testable import _DLUTKit

struct PNGUtilTests {
    @Test func checkCUBEUtil() throws {
        guard let pngURL = Bundle.module.url(forResource: "fuji_eterna_250d_fuji_3510", withExtension: "png") else {
            throw TestError.resourceNotFound("fuji_eterna_250d_fuji_3510.png")
        }
        
        let model = try PNGUtil.buildLUT(from: pngURL)
        print(model)
        
        #expect(model.title == "Fuji Eterna 250D Fuji 3510")
        #expect(model.dimension == 64)
    }
}

