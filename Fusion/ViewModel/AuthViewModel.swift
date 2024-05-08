//
//  AuthViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/12/2023.
//
// Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff
// User Account Deletion: https://developer.apple.com/news/?id=12m75xbj
// CCPA Right to Delete Account: https://securiti.ai/blog/ccpa-right-to-delete/
// ico: https://ico.org.uk/for-the-public/your-right-to-get-your-data-deleted/#:~:text=How%20do%20I%20ask%20for,request%20verbally%20or%20in%20writing

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift



/*
 The AuthViewModel is responsible for everything that has to do with authenticating a user, including signing up and logging in.
 It is also responsible for keeping a record of the user once they have logged in
 */
@MainActor //Main actor ensures my UI changes are published on the main thread
class AuthViewModel: ObservableObject {
    @Published var userSession : FirebaseAuth.User? //tells us if a user is logged in or not, user from database
    @Published var currentUser: User? //user database model
    @Published var authError: AuthError?
    @Published var showAlert = false
    @Published var isLoading = false
    
    //Everytime an AuthViewModel instance is created, I check to see if there is a logged in user or if they have logged in before
    init() {
        userSession = Auth.auth().currentUser
        
        Task {
            isLoading = true
            await fetchUser()
            isLoading = false
        }
    }
    
    //This function is responsible for processing a user's sign in attempt
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
   
    //This function is responsible for processing a users sign up attempt
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
    
    //This function is responsible for signing out a user
    //when signing out it takes you back to log in page and signs user out
    func signout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil //wipes out user session and rakes user back to login screen
            self.currentUser = nil //wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    //This function is responsible for deleting a user's account
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
    
    //This function is responsible for fetching the user's details for when they have logged in or signed up
    func fetchUser() async { //information I get back from database
        guard let uid = Auth.auth().currentUser?.uid else { 
            self.currentUser = User.mockUsers[0]
            return }
        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let user = try? snapshot?.data(as: User.self) else { return }
        self.currentUser = user
    }
    
    //This function is responsible for deleting a user's data https://developer.apple.com/news/?id=12m75xbj
    //CCPA right to delete account: https://securiti.ai/blog/ccpa-right-to-delete/
    //ico: https://ico.org.uk/for-the-public/your-right-to-get-your-data-deleted/#:~:text=How%20do%20I%20ask%20for,request%20verbally%20or%20in%20writing
    func deleteUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).delete()
    }
}

    
    
    
    
    
