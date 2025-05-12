//
//  FilteredImage.swift
//  3DLUTKit
//
//  Created by Denis Dmitriev on 10.05.2025.
//

import SwiftUI
import Kingfisher
@preconcurrency import CoreImage

/// A SwiftUI view that applies a Core Image filter to an image loaded from a URL or provided as a local `UIImage`.
///
/// `FilteredImage` displays an image and applies a specified Core Image filter (e.g., a LUT filter from `LUTModel`) to it. The image can be loaded asynchronously from a remote URL using Kingfisher or provided directly as a `UIImage`. The view manages loading, filtering, and error states, rendering the result through a customizable content closure.
///
/// - Parameters:
///   - url: The URL of the image to load asynchronously. Use this initializer for remote images.
///   - image: A local `UIImage` to display and filter. Use this initializer for images already available in the app.
///   - filter: An optional `CIFilter` to apply to the image (e.g., `CIColorCubeWithColorSpace` for LUTs). If `nil`, the original image is displayed without filtering.
///   - content: A closure that defines how to render the image based on the current phase (loading, success, or failure).
///
/// ### Usage
/// To display and filter a remote image with a LUT:
/// ```swift
/// let url = URL(string: "https://example.com/image.jpg")!
/// FilteredImage(url: url, filter: LUTModel.previewCube.ciFilter) { phase in
///     switch phase {
///     case .loading:
///         ProgressView()
///     case .success(let source, let filtered):
///         VStack {
///             Image(uiImage: source).resizable().scaledToFit()
///             if let filtered {
///                 Image(uiImage: filtered).resizable().scaledToFit()
///             }
///         }
///     case .failure:
///         Image(systemName: "exclamationmark.triangle")
///     }
/// }
/// ```
///
/// To display and filter a local image:
/// ```swift
/// let localImage = UIImage(named: "example")!
/// FilteredImage(image: localImage, filter: LUTModel.previewPng.ciFilter) { phase in
///     // Same content closure as above
/// }
/// ```
///
/// ### Phases
/// The `FilteredImagePhase` enum defines the possible states:
/// - `loading`: The image is being loaded (for URLs) or filtered.
/// - `success(source: UIImage, result: UIImage?)`: The image is loaded successfully. `source` is the original image, and `result` is the filtered image (if a filter was applied).
/// - `failure(Error)`: An error occurred during loading or filtering.
///
/// ### Notes
/// - Remote images are loaded asynchronously using `Kingfisher`.
/// - Image filtering is performed asynchronously on a background thread to avoid blocking the main thread.
/// - Core Image operations are handled by `CIContextManager.shared` for thread-safe processing.
/// - The input image's color space is converted to match the filter's color space (e.g., sRGB or displayP3 for LUTs) to ensure accurate results.
/// - Ensure that the provided `CIFilter` is compatible with the input image's color space.
/// - The view automatically handles errors during image loading or filtering, passing them to the `content` closure.
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
                    loadImage(image: value.image)
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
