//
//  ProfileViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/02/2024.
// 

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    
    @Published var showCamera = false
    @Published var showImageOptions = false
    @Published var uploadIsActive = false
    @Published var uploadProgress: Float = 0
    @Published var avatar: URL?
    @Published var bio: String?
    @Published var experience: String?
    @Published var showLibrary = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""
    @Published var showAlert = false
    @Published var presentEditBio = false
    @Published var presentEditExperience = false
    @Published var company = ""
    var uploadTask: StorageUploadTask?
    
    func updateCompany() { //saving user's company
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
            Firestore.firestore().collection("users").document(userId).updateData(["company": company])
    }
    
    func upload(image: UIImage) { //function takes image from camera
        guard let userId = Auth.auth().currentUser?.uid else { 
            alertTitle = "Upload Error"
            alertMessage = "Your image could not be uploaded right now"
            showAlert = true
            return }
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        let imageID = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        let imageName = imageID + ".jpeg"
        let imagePath = "images/\(userId)/\(imageName)"
        let storageRef = Storage.storage().reference(withPath: imagePath)
        let metaData = StorageMetadata()
        
        metaData.contentType = "image/jpg"
        uploadTask = storageRef.putData(imageData, metadata: metaData) { _, error in
            if let error = error { //error alert
                print(error.localizedDescription)
                self.alertTitle = "Upload Error"
                self.alertMessage = "Your image could not be uploaded right now"
                self.showAlert = true
                self.uploadIsActive = false
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.alertTitle = "Upload Error"
                    self.alertMessage = "Your image could not be uploaded right now"
                    self.showAlert = true
                    self.uploadIsActive = false
                    return
                }
                Firestore.firestore().collection("users").document(userId).updateData(["avatar": url!.absoluteString])
                self.avatar = URL(string: url!.absoluteString)
                self.uploadIsActive = false
            }
        }
        uploadTask!.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
            DispatchQueue.main.async {
                self.uploadProgress = Float(percentComplete)
            }
        }
    }
    
    func save(businessField: BusinessFields) { //this function saves updated the businessfields in firestore
        guard let userid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(userid).updateData([
            "businessField": businessField.rawValue
        ])
                
    }
    
    
}
