//
//  MessageThread.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//

import Foundation
import FirebaseFirestore

/*
 This model describes a message thread
 */
struct MessageThread: Identifiable, Hashable {
    let id: String
    let username: String
    let otherUserID: String
    let threadID: String
    var avatar: URL?
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let username = data["username"] as? String else {
            return nil
        }
        guard let otherUserID = data["otherUserID"] as? String else {
            return nil
        }
        guard let threadID = data["threadID"] as? String else {
            return nil
        }
        self.id = snapshot.documentID
        self.username = username
        self.otherUserID = otherUserID
        self.threadID = threadID
        if let avatar = data["avatar"] as? String,
              let avatarURL = URL(string: avatar) {
            self.avatar = avatarURL
              }
    }
}
