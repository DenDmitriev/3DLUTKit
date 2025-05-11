import Testing
import Foundation
@testable import _DLUTKit

@Test func resourcesExist() async throws {
    let cube = Bundle.module.url(forResource: "Kodachrome 25", withExtension: "cube")
    #expect(cube != nil)
    
    let png = Bundle.module.url(forResource: "fuji_eterna_250d_fuji_3510", withExtension: "png")
    #expect(png != nil)
}
