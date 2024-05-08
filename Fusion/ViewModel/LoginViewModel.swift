//
//  LoginViewModel.swift
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
 The LogicViewModel is the logic behind the LogicView
 */
@MainActor
class LoginViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var authError: AuthError?
    
    //This function is responsible for signing in a user if their email and password match an existing user
    func signIn() async throws -> Bool {
        isLoading = true
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password) //calls signin function
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
    
    //This function is responsible for validating if a user's password is in the correct format
    func isPasswordValid() -> Bool {
        return !password.isEmpty
        && password.count > 5
    }
    
    
}
