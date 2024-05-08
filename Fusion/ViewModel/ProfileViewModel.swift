//
//  ProfileViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/02/2024.
// 
//  Upload Images: https://firebase.google.com/docs/storage/ios/upload-files


import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import FirebaseStorage


/*
 The ProfileViewModel is responsible for handling the logic of the profile view
 This includes displaying the user's current profile data, changing their avatar and so on
 */
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
    
    //This function is responsible for updating the user's company
    func updateCompany() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
            Firestore.firestore().collection("users").document(userId).updateData(["company": company])
    }
    
    //This function is responsible for uploading the user's avatar's image to google's cloud storage https://firebase.google.com/docs/storage/ios/upload-files
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
    
    //This function is responsible for saving updated business fields selection
    func save(businessField: BusinessFields) {
        guard let userid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(userid).updateData([
            "businessField": businessField.rawValue
        ])
                
    }
    
    
}
