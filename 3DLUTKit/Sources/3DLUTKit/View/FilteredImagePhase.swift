//
//  File.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 11.05.2025.
//

import SwiftUI

/// Состояния обработки изображения в `FilteredImage`.
public enum FilteredImagePhase {
    /// Изображение загружается или фильтруется.
    case loading
    /// Изображение успешно загружено.
    /// - Parameters:
    ///   - source: Исходное изображение.
    ///   - result: Отфильтрованное изображение (если применялся фильтр).
    case success(source: UIImage, result: UIImage?)
    /// Произошла ошибка при загрузке или фильтрации.
    /// - Parameter error: Ошибка, описывающая проблему.
    case failure(Error)
}
