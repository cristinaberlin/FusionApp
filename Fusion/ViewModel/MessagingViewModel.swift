//
//  MessagingViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MessagingViewModel: ObservableObject {
    @Published var users: [User] = User.mockUsers
    @Published var messageThreads: [MessageThread] = []
    var listenerRegistration: ListenerRegistration?
    
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
//        Firestore.firestore().collection("users").document(userID).collection("messageThreads").getDocuments { snapshot, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            guard let snapshot = snapshot else {
//                return
//            }
//            self.messageThreads = snapshot.documents.compactMap({ MessageThread(snapshot: $0) })
//        }
    }
}
