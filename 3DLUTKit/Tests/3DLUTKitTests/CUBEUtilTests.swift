//
//  CUBEUtilTests.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import Testing
import Foundation
@testable import _DLUTKit

struct CUBEUtilTests {
    @Test func checkCUBEUtil() throws {
        guard let cubeURL = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube") else {
            throw TestError.resourceNotFound("Kodachrome 25.cube")
        }
        
        let model = try CUBEUtil.buildLUT(from: cubeURL)
        
        #expect(model.title == "Kodachrome 25")
        #expect(model.dimension == 33)
    }
}
