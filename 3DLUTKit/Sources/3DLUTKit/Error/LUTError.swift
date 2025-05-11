//
//  LUTError.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

enum LUTError: LocalizedError {
    case fileNotSupported(String)
    case fileNotFound(String)
    case filterOutputFailed
    case invalidFormat(String)
    case missingDimension
    case invalidDataSize(expected: Int, actual: Int)
    case filterCreationFailed
    case invalidImage
}
