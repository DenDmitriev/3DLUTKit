import Testing
import Foundation
@testable import _DLUTKit

@Test func resourcesExist() async throws {
    let cube = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube")
    #expect(cube != nil)
    
    let png = Bundle.module.url(forResource: "fuji_eterna_250d_fuji_3510", withExtension: "png")
    #expect(png != nil)
    
    let cube65 = Bundle.module.url(forResource: "ARRI_LogC4-to-Gamma24_Rec709-D65_v1-65", withExtension: "cube")
    #expect(cube65 != nil)
}
