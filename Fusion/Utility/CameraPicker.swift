//
//  CameraPicker.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/02/2024.
//  
//  Inspired by: https://medium.com/@jakir/access-the-camera-and-photo-library-in-swiftui-0351a3c280f5

import Foundation
import SwiftUI


/*
 The CameraPicker is responsable bringing up the user's iphone camera to take photos for their user's profile
 */
struct CameraPicker: UIViewControllerRepresentable { //importing controller from ui kit to swift ui
    
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .camera
    var action: (UIImage) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        imagePicker.cameraViewTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraPicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                //parent.selectedImage = image
                parent.action(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
}
