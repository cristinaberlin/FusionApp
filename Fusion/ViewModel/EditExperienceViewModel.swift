//
//  EditExperienceViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 05/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/*
 This EditExperienceViewModel handles the logic behind the EditExperienceView
 */
class EditExperienceViewModel: ObservableObject{
    @Published var experience = ""
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var presentAlert = false
    let characterLimit = 450
    
    //This function is responsible for saving and updating the user's experience to firebase
    func saveExperience() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertTitle = "Error"
            alertMessage = "You need to be logged in to save experience"
            presentAlert = true
            return false}
        guard experience.count >= 5 else { //checks experience is not empty and has min character count of 5
            alertTitle = "Error"
            alertMessage = "Minimum Character Amount is 5"
            presentAlert = true
            return false
        }
        do {
            try await Firestore.firestore().collection("users").document(userId).updateData(["experience": experience])
            return true
        } catch { //catch block showing error message incase experience doesnt upload
            alertTitle = "Error"
            alertMessage = "Unable to upload experience, Check internet connection"
            presentAlert = true
            return false
        }
       
        
    }
    
}
