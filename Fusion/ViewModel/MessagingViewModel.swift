//
//  MessagingViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//
//  Inspired By: https://github.com/rick2785/SwiftUIFirebaseChat

import Foundation
import FirebaseFirestore
import FirebaseAuth

/*
 This MessagingViewModel is the logic behind the MessagingView.
 */
class MessagingViewModel: ObservableObject {
    @Published var users: [User] = User.mockUsers
    @Published var messageThreads: [MessageThread] = []
    @Published var selectedMessageThread: MessageThread?
    var listenerRegistration: ListenerRegistration?
    
    //This function is responsible for getting all the message threads from firebase
    func getThreads() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        guard listenerRegistration == nil else {
            return
        }
       listenerRegistration = Firestore.firestore().collection("users").document(userID).collection("messageThreads").addSnapshotListener { snapshot, error in //listens to any changes in message threads, eg new people to chat to or new messages
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            self.messageThreads = snapshot.documents.compactMap({ MessageThread(snapshot: $0) })
        }
    }
}
