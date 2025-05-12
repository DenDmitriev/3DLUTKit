//
//  LUTType.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import Foundation

public enum LUTType {
    case cube
    case palette
    
    public init?(url: URL) {
        if url.pathExtension.lowercased() == "cube" {
            self = .cube
        } else if url.pathExtension.lowercased() == "png" {
            self = .palette
        } else {
            return nil
        }
    }
}

