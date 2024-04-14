//
//  MessageThread.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//

import Foundation
import FirebaseFirestore

struct MessageThread: Identifiable {
    let id: String
    let username: String
    var avatar: URL?
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let username = data["username"] as? String else {
            return nil
        }
        self.id = snapshot.documentID
        self.username = username
        if let avatar = data["avatar"] as? String,
              let avatarURL = URL(string: avatar) {
            self.avatar = avatarURL
              }
    }
}
