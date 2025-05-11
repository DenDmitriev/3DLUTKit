//
//  FilteredImage.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import SwiftUI
import Kingfisher
@preconcurrency import CoreImage

public enum FilteredImagePhase {
    case loading
    case success(source: Image, result: Image?)
    case failure(Error)
}

public struct FilteredImage<Content>: View where Content: View {
    let url: URL?
    let filter: CIFilter?
    nonisolated let context: CIContext?
    let content: (FilteredImagePhase) -> Content
    
    @State private var phase: FilteredImagePhase = .loading
    
    init(
        url: URL?,
        filter: CIFilter?,
        context: CIContext? = nil,
        content: @escaping (FilteredImagePhase) -> Content
    ) {
        self.url = url
        self.filter = filter
        self.context = context
        self.content = content
    }
    
    public var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        guard let url = url else {
            phase = .failure(NSError(domain: "No URL", code: 0))
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                let rawImage = Image(uiImage: value.image)
                Task { @MainActor in
                    self.phase = .success(source: rawImage, result: nil)
                    if let filter = self.filter {
                        Task(priority: .userInitiated) {
                            let filteredUIImage = self.applyFilter(to: value.image, filter: filter)
                            let filteredImage = Image(uiImage: filteredUIImage)
                            Task { @MainActor in
                                self.phase = .success(source: rawImage, result: filteredImage)
                            }
                        }
                    }
                }
            case .failure(let error):
                Task { @MainActor in
                    self.phase = .failure(error)
                }
            }
        }
    }
    
    nonisolated private func applyFilter(to image: UIImage, filter: CIFilter) -> UIImage {
        let context = context ?? CIContext()
        guard
            let inputImage = CIImage(image: image)
        else {
            return image
        }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        guard
            let outputImage = filter.outputImage,
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
}

fileprivate let url = URL(string: "https://www.beauphoto.com/wp-content/uploads/scanners-printers-amp-colourman/Calibrite/CCC_PT02_Model.jpg")

#Preview("Sepia") {
    FilteredImage(url: url, filter: CIFilter(name: "CISepiaTone"), context: CIContextManager.shared.context) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    source
                        .resizable()
                        .scaledToFit()
                    
                    if (filtered != nil) {
                        filtered!
                            .resizable()
                            .scaledToFit()
                    } else {
                        ProgressView().scaleEffect(0.5)
                    }
                }
            case .failure:
                Image(systemName: "exclamationmark.triangle")
            }
        }
    }
}

#Preview("LUT") {
    FilteredImage(url: url, filter: LUTModel.preview.ciFilter, context: CIContextManager.shared.context) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    source
                        .resizable()
                        .scaledToFit()
                    
                    if (filtered != nil) {
                        filtered!
                            .resizable()
                            .scaledToFit()
                    } else {
                        ProgressView().scaleEffect(0.5)
                    }
                }
            case .failure:
                Image(systemName: "exclamationmark.triangle")
            }
        }
    }
}
