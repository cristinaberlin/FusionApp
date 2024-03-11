//
//  AuthViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/12/2023.
// AuthViewModel is responsible for everything that has to do with authenticating a user, updating UI, errors and networking
// Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol{ //Everywhere there is a form e.g sign up, This authentication form protocol will be implemented which will determine the logic whether or not the form is valid
    var formIsValid: Bool { get }
}


@MainActor //Main actor ensures my UI changes are published on the main thread
class AuthViewModel: ObservableObject {
    @Published var userSession : FirebaseAuth.User? //tells us if a user is logged in or not, user from database
    @Published var currentUser: User? //user database model
    @Published var authError: AuthError?
    @Published var showAlert = false
    @Published var isLoading = false
    
    init() {
        userSession = Auth.auth().currentUser
        
        Task {
            isLoading = true
            await fetchUser()
            isLoading = false
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password) //calls signin function
            await fetchUser()//fetches user from database
            self.userSession = result.user
            isLoading = false
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.showAlert = true
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            isLoading = false
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, businessField: BusinessFields) async throws { //creates a user in background with firebase
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password) //what I get back from firebase packet manager
            self.userSession = result.user //once I get data back, I set the user session property
            let user = User(id: result.user.uid, fullname: fullname, email: email, businessField: businessField)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            await fetchUser()
            isLoading = false
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.showAlert = true
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            isLoading = false
        }
    }
    
    func signout() { //when signing out it takes you back to log in page and signs user out
        do {
            try Auth.auth().signOut()
            self.userSession = nil //wipes out user session and rakes user back to login screen
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
            self.userSession = nil
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func fetchUser() async { //information I get back from database
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("did find id")
        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        print("did find snapshot \(snapshot)")
        guard let user = try? snapshot?.data(as: User.self) else { return }
        print("did get user")
        self.currentUser = user
    }
    
    func deleteUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).delete()
    }
}

    
    
    
    
    
