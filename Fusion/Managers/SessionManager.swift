//
//  ServiceManager.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 29/03/2024.
//  
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/*
 This manages a user session and changes whether the user is in the main views(The MessagingView, HomeView and ProfileView) or the AuthView
 */

@MainActor //changes will happen on main thread
class SessionManager: ObservableObject {
    
    @Published var sessionState: SessionState = .loggedOut  {
        didSet{
            if sessionState == .loggedIn{
                Task {
                    await fetchUser()
                }
            }
        }
    }//default
    
    @Published var currentUser: User?
    @Published var isLoading = false
    
    init(currentUser: User? = nil) {
        if Auth.auth().currentUser != nil {
                       self.sessionState = .loggedIn //if there is a current user they will stay logged in
                       Task{
                           self.fetchUser
                       }
                   } else {
                       self.sessionState = .loggedOut //else if there is no user they will stay logged out
                   }
    }
        
    func fetchUser() async { //information I get back from database
        guard let uid = Auth.auth().currentUser?.uid else {
         
            return }
        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let user = try? snapshot?.data(as: User.self) else { return }
        self.currentUser = user
    }
    
    func signout() { //when signing out it takes you back to log in page and signs user out
        do {
            try Auth.auth().signOut()
            self.sessionState = .loggedOut //wipes out user session and takes user back to login screen
            self.currentUser = nil //wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await Auth.auth().currentUser?.delete()
            deleteUserData()
            self.currentUser = nil
            self.sessionState = .loggedOut
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }
    
    func deleteUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).delete()
    }
    
    func sendResetPasswordLink(toEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    
}
