//
//  Chat.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 16/04/2024.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable {
    let id: String
    let userID: String
    let text: String
    let createdAt: Date
    
    init(id: String, userID: String, text: String) {
        self.id = id
        self.userID = userID
        self.text = text
        self.createdAt = Date()
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let userID = data["userID"] as? String else { return nil }
        guard let text = data["text"] as? String else { return nil }
        guard let createdAt = data["createdAt"] as? Double else { return nil }
        self.id = snapshot.documentID
        self.userID = userID
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: createdAt)
    }
}
