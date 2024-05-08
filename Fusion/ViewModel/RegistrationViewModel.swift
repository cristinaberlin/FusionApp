//
//  RegistrationViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/03/2024.
//
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

/*
 The RegistrationViewModel is responsible behind the logic for the RegistrationView
 */
class RegistrationViewModel: ObservableObject{
    @Published var userSession : FirebaseAuth.User? //tells us if a user is logged in or not, user from database
    @Published var currentUser: User? //user database model
    @Published var authError: AuthError?
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var email = ""
    @Published var fullname = ""
    @Published var businessFieldSelection: BusinessFields = .marketing //default that is shown in picker if no prior selection
    @Published var password = ""
    @Published var confirmPassword = ""
    
    //This function is responsible for creating a user only if their email and password credentials are valid
    func createUser() async throws -> Bool {
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password) //what I get back from firebase packet manager
            self.userSession = result.user //once I get data back, I set the user session property
            let user = User(id: result.user.uid, fullname: fullname, email: email, businessField: businessFieldSelection)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return false }
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            isLoading = false
            return true
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.showAlert = true
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            isLoading = false
            return false
        }
    }
    //This function is responsible for validating if a user's email is in the correct format
    func isEmailValid() -> Bool {
        return !email.isEmpty
        && email.contains("@")
    }
    
    //This function is responsible for validating that the user's password is in the correct format
    func isPasswordValid() -> Bool {
        return !password.isEmpty
        && password.count > 5
        && confirmPassword == password
    }
    
    //This function is responsible for validating that the user's name is in the correct format
    func isFullnameValid() -> Bool {
        return !fullname.isEmpty
        && fullname.count > 3
    }
    
    
    
}


