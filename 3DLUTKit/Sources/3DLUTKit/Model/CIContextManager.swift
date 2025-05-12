//
//  CIContextManager.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

@preconcurrency import CoreImage

final class CIContextManager: Sendable {
    static let shared = CIContextManager()
    private let context: CIContext
    private let queue = DispatchQueue(label: "com.3DLUTKit.CIContextManager", attributes: .concurrent)

    private init() {
        self.context = CIContext(options: [.workingColorSpace: NSNull()])
    }

    func withContext<T>(_ block: (CIContext) throws -> T) rethrows -> T {
        try queue.sync {
            try block(context)
        }
    }
}
