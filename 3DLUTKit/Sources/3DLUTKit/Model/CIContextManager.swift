//
//  CIContextManager.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import CoreImage

/// Потокобезопасный контейнер для CIContext
///
/// Будет управлять единственным экземпляром CIContext и предоставлять потокобезопасный доступ к нему.
class CIContextManager: @unchecked Sendable {
    static let shared = CIContextManager()
    let context: CIContext

    private init() {
        self.context = CIContext(options: [.workingColorSpace: NSNull()])
    }

    func createCGImage(_ image: CIImage, from rect: CGRect) -> CGImage? {
        context.createCGImage(image, from: rect)
    }
    
    func clearCache() {
        context.clearCaches()
    }
}
