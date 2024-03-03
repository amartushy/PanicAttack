//
//  CachedAsyncImageView.swift
//  locale
//
//  Created by Adrian Martushev on 2/24/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()

    static func getImage(forKey key: String) -> UIImage? {
        return shared.object(forKey: key as NSString)
    }

    static func setImage(_ image: UIImage, forKey key: String) {
        shared.setObject(image, forKey: key as NSString)
    }
}

class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var urlString: String
    private var cancellable: AnyCancellable?

    init(urlString: String) {
        self.urlString = urlString
    }

    func load() {
        if let cachedImage = ImageCache.getImage(forKey: urlString) {
            image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else {
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let image = $0 {
                    ImageCache.setImage(image, forKey: self?.urlString ?? "")
                    self?.image = image
                }
            }
    }

    func cancel() {
        cancellable?.cancel()
    }
}

struct CachedAsyncImageView: View {
    @StateObject private var loader: CachedImageLoader
    init(urlString: String) {
        _loader = StateObject(wrappedValue: CachedImageLoader(urlString: urlString))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loader.load)
        .onDisappear(perform: loader.cancel)
    }
}
