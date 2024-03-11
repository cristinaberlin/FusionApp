//
//  EditBioViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class EditBioViewModel: ObservableObject{
    @Published var bio = ""
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var presentAlert = false
    let characterLimit = 300
    
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
