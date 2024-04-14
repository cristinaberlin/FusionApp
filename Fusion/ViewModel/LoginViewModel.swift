//
//  LoginViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/03/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

@MainActor
class LoginViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var authError: AuthError?
    
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
    
    func isEmailValid() -> Bool {
        return !email.isEmpty
        && email.contains("@")
    }
    
    func isPasswordValid() -> Bool {
        return !password.isEmpty
        && password.count > 5
    }
    
    
}
