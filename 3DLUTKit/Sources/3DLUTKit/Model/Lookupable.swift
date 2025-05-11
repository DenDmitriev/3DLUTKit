//
//  Lookupable.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

protocol Lookupable: Sendable {
    static func buildLUT(from url: URL) throws -> LUTModel
    static func prettifyFileName(_ fileName: String) -> String
}

extension Lookupable {
    static func prettifyFileName(_ fileName: String) -> String {
        let nameWithoutExtension = fileName.components(separatedBy: ".").first ?? fileName
        let replaced = nameWithoutExtension
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        let capitalized = replaced
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
        return capitalized
    }
}
