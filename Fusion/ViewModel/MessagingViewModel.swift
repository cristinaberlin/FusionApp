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
    
    func getThreads() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("users").document(userID).collection("messageThreads").getDocuments { snapshot, error in
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
