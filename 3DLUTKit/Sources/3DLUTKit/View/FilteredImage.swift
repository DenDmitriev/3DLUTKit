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
    case success(source: UIImage, result: UIImage?)
    case failure(Error)
}

public struct FilteredImage<Content>: View where Content: View {
    enum InputImage {
        case url(URL)
        case image(UIImage)
    }
    
    let inputImage: InputImage
    let filter: CIFilter?
    let content: (FilteredImagePhase) -> Content
    
    @State private var phase: FilteredImagePhase = .loading
    
    init(
        url: URL,
        filter: CIFilter?,
        content: @escaping (FilteredImagePhase) -> Content
    ) {
        self.inputImage = .url(url)
        self.filter = filter
        self.content = content
    }
    
    init(
        image: UIImage,
        filter: CIFilter?,
        content: @escaping (FilteredImagePhase) -> Content
    ) {
        self.inputImage = .image(image)
        self.filter = filter
        self.content = content
    }
    
    public var body: some View {
        switch inputImage {
        case .url(let url):
            content(phase)
                .onAppear {
                    loadImage(url: url)
                }
        case .image(let uiImage):
            content(phase)
                .onAppear {
                    loadImage(image: uiImage)
                }
        }
    }
    
    private func loadImage(image: UIImage) {
        Task { @MainActor in
            self.phase = .success(source: image, result: nil)
            if let filter {
                Task(priority: .userInitiated) {
                    let filteredImage = self.applyFilter(to: image, filter: filter)
                    Task { @MainActor in
                        self.phase = .success(source: image, result: filteredImage)
                    }
                }
            }
        }
    }
    
    private func loadImage(url: URL) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                Task { @MainActor in
                    self.phase = .success(source: value.image, result: nil)
                    if let filter {
                        Task(priority: .userInitiated) {
                            let filteredImage = self.applyFilter(to: value.image, filter: filter)
                            Task { @MainActor in
                                self.phase = .success(source: value.image, result: filteredImage)
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
        guard let inputImage = CIImage(image: image) else {
            return image
        }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return CIContextManager.shared.withContext { context in
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return image
            }
            return UIImage(cgImage: cgImage)
        }
    }
}

fileprivate let url = URL(string: "https://www.beauphoto.com/wp-content/uploads/scanners-printers-amp-colourman/Calibrite/CCC_PT02_Model.jpg")!

#Preview("Sepia") {
    FilteredImage(url: url, filter: CIFilter(name: "CISepiaTone")) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    Image(uiImage: source)
                        .resizable()
                        .scaledToFit()
                    
                    if let filtered {
                        Image(uiImage: filtered)
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

#Preview("LUT CUBE") {
    FilteredImage(url: url, filter: LUTModel.previewCube.ciFilter) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    Image(uiImage: source)
                        .resizable()
                        .scaledToFit()
                    
                    if let filtered {
                        Image(uiImage: filtered)
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

#Preview("LUT PNG") {
    FilteredImage(url: url, filter: LUTModel.previewPng.ciFilter) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    Image(uiImage: source)
                        .resizable()
                        .scaledToFit()
                    
                    if let filtered {
                        Image(uiImage: filtered)
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

#Preview("Local Image") {
    let image: UIImage = {
        let imageURL = Bundle.module.url(forResource: "ColorCheckerPortrait", withExtension: "jpeg")!
        let imageData = (try? Data(contentsOf: imageURL)) ?? Data()
        return UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.triangle")!
    }()
    FilteredImage(image: image, filter: LUTModel.previewPng.ciFilter) { phase in
        Group {
            switch phase {
            case .loading:
                ProgressView()
            case .success(let source, let filtered):
                VStack {
                    Image(uiImage: source)
                        .resizable()
                        .scaledToFit()
                    
                    if let filtered {
                        Image(uiImage: filtered)
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
