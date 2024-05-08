//
//  EditBioViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/*
 This EditBioViewModel is the logic behind EditBioView, its major responsibility is to update the user's bio
 */
class EditBioViewModel: ObservableObject{
    @Published var bio = ""
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var presentAlert = false
    let characterLimit = 300
    
    //This function is responsible for updating user's bio
    func saveBio() async -> Bool { //saving bio to firebase
        guard let userId = Auth.auth().currentUser?.uid else {return false}
        do {
            try await Firestore.firestore().collection("users").document(userId).updateData(["bio": bio])
            return true
        } catch { //catch block showing error message incase bio doesnt upload
            alertTitle = "Error"
            alertMessage = "Unable to upload bio, Check internet connection"
            presentAlert = true
            return false
        }
       
        
    }
    
}
