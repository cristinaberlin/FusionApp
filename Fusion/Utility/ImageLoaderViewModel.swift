//
//  ImageLoaderViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/02/2024.
//
//  Inspired by: https://medium.com/@jakir/access-the-camera-and-photo-library-in-swiftui-0351a3c280f5


import Foundation
import PhotosUI
import SwiftUI

/*
 The ImageLoaderViewModel is responsable allowing a user to pick a photo from the user library to show as their user avatar
 */
enum ImageState {
    case empty
    case loading(Progress)
    #if os(iOS)
    case success(UIImage)
    #elseif os(macOS)
    case success(NSImage)
    #endif
    case failure(Error)
}

@MainActor
class ImageLoaderViewModel: ObservableObject {
    
    @Published var imageState: ImageState = .empty
    @Published var imageToUpload: UIImage?
    @Published var showLoadingView = false
    @Published var showPreview = false
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
                showLoadingView = true
            } else {
                imageState = .empty
                showLoadingView = false
            }
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ImageSnippet: Transferable {
        
        #if os(iOS)
        let image: UIImage
        #elseif os(macOS)
        let image: NSImage
        #endif
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                //let image = Image(nsImage: nsImage)
                //let image = UIImage(data: data)
                return ImageSnippet(image: nsImage)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    print("DEBUG: import image conversion failed")
                    throw TransferError.importFailed
                }
                //let image = Image(uiImage: uiImage)
                return ImageSnippet(image: uiImage)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ImageSnippet.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let snippetImage?):
                    self.showLoadingView = false
                    self.imageState = .success(snippetImage.image)
                    self.imageToUpload = snippetImage.image
                    self.showPreview = true
                case .success(nil):
                    self.showLoadingView = false
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
}

