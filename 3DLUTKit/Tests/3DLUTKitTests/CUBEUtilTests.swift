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
    
    @Test func checkCubeDimension33() throws {
        guard let cubeURL = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube") else {
            throw TestError.resourceNotFound("Kodachrome 25.cube")
        }
        
        let model = try CUBEUtil.buildLUT(from: cubeURL)
        
        #expect(model.title == "Kodachrome 25")
        #expect(model.dimension == 33)
    }
    
    @Test func checkCubeDimension65() throws {
        guard let cubeURL = Bundle.module.url(forResource: "ARRI_LogC4-to-Gamma24_Rec709-D65_v1-65", withExtension: "cube") else {
            throw TestError.resourceNotFound("ARRI_LogC4-to-Gamma24_Rec709-D65_v1-65.cube")
        }
        
        let model = try CUBEUtil.buildLUT(from: cubeURL)
        
        #expect(model.dimension == 65)
    }
    
    @Test func checkCubeDimension17() throws {
        guard let cubeURL = Bundle.module.url(forResource: "Contrast17", withExtension: "cube") else {
            throw TestError.resourceNotFound("Contrast17.cube")
        }
        
        let model = try CUBEUtil.buildLUT(from: cubeURL)
        
        #expect(model.dimension == 17)
    }
}
