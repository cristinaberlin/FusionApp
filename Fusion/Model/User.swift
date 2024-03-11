//
//  User.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/12/2023.
//
// User model

import Foundation


struct User: Identifiable, Codable, Equatable, Hashable { 
    let id: String
    let fullname: String
    let email: String
    let businessField: BusinessFields
    var company: String?
    var experience: String?
    var bio: String?
    var avatar: String?
    
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) { //looks at full name and grabs initials
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
}


extension User{ //creating mock user
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Cristina Berlinschi", email: "test@gmail.com", businessField: .marketing)
    static let mockUsers: [User] = [
        User(id: UUID().uuidString, fullname: "Pink Panther", email: "panther32@gmail.com", businessField: .hospitality, company: "Hilton", experience: "3 years", bio: "I love cheese", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Ana Banana", email: "ana123@icloud.com", businessField: .fashion, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Tony B", email: "tony98@icloud.com", businessField: .automotive, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Alejandro D", email: "ad32@icloud.com", businessField: .healthcare, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Kevin B", email: "kevin28@icloud.com", businessField: .accounting, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Alexandra T", email: "alex@icloud.com", businessField: .technology, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Amelia B", email: "amelia6@icloud.com", businessField: .marketing, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab")
        
    ]
}
