//
//  LUTError.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

public enum LUTError: LocalizedError {
    /// Файл имеет неподдерживаемый формат (например, неверное расширение).
    case fileNotSupported(String)
    /// Файл не найден по указанному пути.
    case fileNotFound(String)
    /// Не удалось получить выходное изображение из фильтра.
    case filterOutputFailed
    /// Формат файла или данные недействительны.
    case invalidFormat(String)
    /// Отсутствует размер LUT (dimension) в файле.
    case missingDimension
    /// Размер данных LUT не соответствует ожидаемому.
    case invalidDataSize(expected: Int, actual: Int)
    /// Не удалось создать фильтр Core Image.
    case filterCreationFailed
    /// Входное изображение недействительно или не может быть обработано.
    case invalidImage
    /// Цветовая схема не поддерживается устройством
    case colorSpaceNotSupported(String)
    /// Значение из таблицы не действительно
    case invalidLUTValue(String)
    case colorSpaceMismatch(expected: String, actual: String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotSupported(let file):
            return "File \(file) is not supported."
        case .fileNotFound(let file):
            return "File \(file) not found."
        case .filterOutputFailed:
            return "Failed to generate output from filter."
        case .invalidFormat(let reason):
            return "Invalid format: \(reason)."
        case .missingDimension:
            return "LUT dimension is missing."
        case .invalidDataSize(let expected, let actual):
            return "Invalid data size. Expected \(expected), but got \(actual)."
        case .filterCreationFailed:
            return "Failed to create Core Image filter."
        case .invalidImage:
            return "Invalid or unsupported image."
        case .colorSpaceNotSupported(let reason):
            return "Color space not supported: \(reason)."
        case .invalidLUTValue(let reason):
            return "Invalid LUT value: \(reason)."
        case .colorSpaceMismatch(let expected, let actual):
            return "Color space mismatch. Expected \(expected), but got \(actual)."
        }
    }
}
